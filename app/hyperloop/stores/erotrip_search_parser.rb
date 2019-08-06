class ErotripSearchParser < Hyperloop::Store
  def self.encode(data, options = {})
    if options[:before_encode].present?
      data = options[:before_encode].call(data)
    end

    data.map do |key, val|
      name = key
      # `encodeURIComponent(#{key})`
      if val.instance_of?(Array) && val.size > 0
        val.map do |v|
          v = Native(`encodeURIComponent(#{v})`)
          "#{name}[]=#{v}"
        end.join("&")
      else
        val = Native(`encodeURIComponent(#{val})`)
        "#{key}=#{val}"
      end
    end.join("&")
  end

  def self.decode(search_string, options = {})
    self.prepare(self.parse_search(search_string), options)
  end

  def self.parse_search search_string
    hash = {}
    search_string[1..-1].split('&').map do |part|
      name, value = part.split('=')

      # name  = `decodeURIComponent(#{name})`
      name = Native(`decodeURIComponent(#{name})`)

      # value = value.present? ? value.to_s : ''
      value = Native(`decodeURIComponent(#{value})`)

      if name.end_with?("[]")
        name = name[0..-3]
        hash[name] = (hash[name] || []) + [value]
      else
        hash[name] = value
      end
    end
    hash
    # puts Hyperloop::Application
    # puts Hyperloop::Application.try(:params)
    # puts Hyperloop::Application.try(:@params)
    # puts Hyperloop::Application.try(:request_params)
    # # puts Hyperloop::Application.methods
    # # puts JSON.parse(`window.HyperloopRequestParams`)
    # # JSON.parse(`window.HyperloopRequestParams`)
    # Hyperloop::Application.try(:request_params) || {}
  end

  def self.prepare(hash, options = {})
    options[:parse][:numeric_or_nil].each do |key|
      hash[key] = self.to_numeric_or_nil(hash[key])
    end if options[:parse][:numeric_or_nil].present?

    options[:parse][:boolean_or_nil].each do |key|
      hash[key] = self.to_boolean_or_nil(hash[key])
    end if options[:parse][:boolean_or_nil].present?

    options[:parse][:array_or_empty_array].each do |key|
      hash[key] = self.to_array_or_empty_array(hash[key])
    end if options[:parse][:array_or_empty_array].present?

    options[:parse][:array_or_nil].each do |key|
      hash[key] = self.to_array_or_nil(hash[key])
    end if options[:parse][:array_or_nil].present?

    options[:parse][:string_or_empty_string].each do |key|
      hash[key] = hash[key].present? ? hash[key] : ""
    end if options[:parse][:string_or_empty_string].present?

    options[:parse][:array_values_to_int].each do |key|
      if hash[key].present? && hash[key].size > 0
        hash[key] = hash[key].map do |json_int|
          self.to_numeric_or_nil(json_int)
        end.compact
      end
    end if options[:parse][:array_values_to_int].present?

    # if options[:after_decode].present?
    #   options[:after_decode].call(hash)
    if options[:parse_scope].present?
      if !hash["#{options[:parse_scope]}birth_year_gteq"] || hash["#{options[:parse_scope]}birth_year_gteq"] == nil
        hash["#{options[:parse_scope]}birth_year_gteq"] = Time.now.year - 50
      end

      if !hash["#{options[:parse_scope]}city_eq"] || hash["#{options[:parse_scope]}city_eq"] == ""
        hash["#{options[:parse_scope]}find_in_bounds"] = nil
        hash["#{options[:parse_scope]}within_range"] = [0, nil]
      else
        if hash["#{options[:parse_scope]}within_range_distance"] && hash["#{options[:parse_scope]}within_range_location"]
          hash["#{options[:parse_scope]}within_range"] = [hash["#{options[:parse_scope]}within_range_distance"], hash["#{options[:parse_scope]}within_range_location"]]
        end

        if hash["#{options[:parse_scope]}find_in_bounds_sw_lon"] && hash["#{options[:parse_scope]}find_in_bounds_ne_lon"]
          hash["#{options[:parse_scope]}find_in_bounds"] = [
            [self.to_numeric_or_nil(hash["#{options[:parse_scope]}find_in_bounds_sw_lon"]), self.to_numeric_or_nil(hash["#{options[:parse_scope]}find_in_bounds_sw_lat"])],
            [self.to_numeric_or_nil(hash["#{options[:parse_scope]}find_in_bounds_ne_lon"]), self.to_numeric_or_nil(hash["#{options[:parse_scope]}find_in_bounds_ne_lat"])]
          ]
        end

        hash["#{options[:parse_scope]}within_range"][0] = self.to_numeric_or_nil(hash["#{options[:parse_scope]}within_range"][0])
        hash["#{options[:parse_scope]}within_range"][1] = self.to_array_or_nil(hash["#{options[:parse_scope]}within_range"][1])

        if hash["#{options[:parse_scope]}within_range"][1]
          hash["#{options[:parse_scope]}within_range"][1] = hash["#{options[:parse_scope]}within_range"][1].each do |json_number|
            self.to_numeric_or_nil(json_number)
          end
        end
      end

      hash
    else
      hash
    end
  end

  def self.to_string_or_nil json_string
    #     if json_string || json_string == ""
    if json_string.blank?
      nil
    else
      json_string
    end
  end

  def self.to_numeric_or_nil json_number
    # if json_number == ""
    if json_number.blank?
      nil
    else
      json_number.to_f
    end
  end

  def self.to_boolean_or_nil json_boolean
    # if json_boolean.to_s == 'true'
    if json_boolean.try(:to_s) == 'true'
      true
    elsif json_boolean.try(:to_s) == 'false'
      false
    else
      nil
    end
  end

  def self.to_array_or_empty_array json_array
    # if !json_array || json_array == ""
    if json_array.blank?
      []
    else
      Array.new(Native(json_array))
    end
  end

  def self.to_array_or_nil json_array
    # if !json_array || json_array == ""
    if json_array.blank?
      nil
    else
      Array.new(Native(json_array))
    end
  end
end