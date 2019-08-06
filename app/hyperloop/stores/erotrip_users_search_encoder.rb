class ErotripUsersSearchEncoder < Hyperloop::Store
  def self.handle_encode(data, parse_scope = '')
    data.delete("#{parse_scope}within_range_location")
    data.delete("#{parse_scope}within_range_distance")
    data.delete("#{parse_scope}find_in_bounds_sw_lon")
    data.delete("#{parse_scope}find_in_bounds_sw_lat")
    data.delete("#{parse_scope}find_in_bounds_ne_lon")
    data.delete("#{parse_scope}find_in_bounds_ne_lat")

    if data["#{parse_scope}within_range"].present?
      data["#{parse_scope}within_range_distance"] = data["#{parse_scope}within_range"][0]
      data["#{parse_scope}within_range_location"] = data["#{parse_scope}within_range"][1]
    end

    if data["#{parse_scope}find_in_bounds"].present? && data["#{parse_scope}find_in_bounds"][0].present? && data["#{parse_scope}find_in_bounds"][1].present?
      data["#{parse_scope}find_in_bounds_sw_lon"] = data["#{parse_scope}find_in_bounds"][0][0]
      data["#{parse_scope}find_in_bounds_sw_lat"] = data["#{parse_scope}find_in_bounds"][0][1]
      data["#{parse_scope}find_in_bounds_ne_lon"] = data["#{parse_scope}find_in_bounds"][1][0]
      data["#{parse_scope}find_in_bounds_ne_lat"] = data["#{parse_scope}find_in_bounds"][1][1]
    end

    proper_data = {}
    data.keys.each do |key|
      proper_data[key] = data[key] if data[key].present?
    end

    # if data["#{parse_scope}within_range"] && data["#{parse_scope}within_range"][0] && data["#{parse_scope}within_range"][0] != 0
    #   data["#{parse_scope}within_range_distance"] = data["#{parse_scope}within_range"][0]
    #   data["#{parse_scope}within_range_location"] = data["#{parse_scope}within_range"][1]
    # elsif data["#{parse_scope}find_in_bounds"] && data["#{parse_scope}find_in_bounds"][0] && data["#{parse_scope}find_in_bounds"][1]
    #   data["#{parse_scope}find_in_bounds_sw_lon"] = data["#{parse_scope}find_in_bounds"][0][0]
    #   data["#{parse_scope}find_in_bounds_sw_lat"] = data["#{parse_scope}find_in_bounds"][0][1]
    #   data["#{parse_scope}find_in_bounds_ne_lon"] = data["#{parse_scope}find_in_bounds"][1][0]
    #   data["#{parse_scope}find_in_bounds_ne_lat"] = data["#{parse_scope}find_in_bounds"][1][1]
    # end

    proper_data
  end

  def self.handle_decode(hash, parse_scope = '')
    if !hash["#{parse_scope}birth_year_gteq"] || hash["#{parse_scope}birth_year_gteq"] == nil
      hash["#{parse_scope}birth_year_gteq"] = Time.now.year - 50
    end

    if !hash["#{parse_scope}city_eq"] || hash["#{parse_scope}city_eq"] == ""
      hash["#{parse_scope}find_in_bounds"] = nil
      hash["#{parse_scope}within_range"] = [0, nil]
    else
      if hash["#{parse_scope}within_range_distance"] && hash["#{parse_scope}within_range_location"]
        hash["#{parse_scope}within_range"] = [hash["#{parse_scope}within_range_distance"], hash["#{parse_scope}within_range_location"]]
      end

      if hash["#{parse_scope}find_in_bounds_sw_lon"] && hash["#{parse_scope}find_in_bounds_ne_lon"]
        hash["#{parse_scope}find_in_bounds"] = [
          [self.to_numeric_or_nil(hash["#{parse_scope}find_in_bounds_sw_lon"]), self.to_numeric_or_nil(hash["#{parse_scope}find_in_bounds_sw_lat"])],
          [self.to_numeric_or_nil(hash["#{parse_scope}find_in_bounds_ne_lon"]), self.to_numeric_or_nil(hash["#{parse_scope}find_in_bounds_ne_lat"])]
        ]
      end

      hash["#{parse_scope}within_range"][0] = self.to_numeric_or_nil(hash["#{parse_scope}within_range"][0])
      hash["#{parse_scope}within_range"][1] = self.to_array_or_nil(hash["#{parse_scope}within_range"][1])

      if hash["#{parse_scope}within_range"][1]
        hash["#{parse_scope}within_range"][1] = hash["#{parse_scope}within_range"][1].each do |json_number|
          self.to_numeric_or_nil(json_number)
        end
      end
    end

    hash
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