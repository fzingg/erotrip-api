class ApplicationRecord < ActiveRecord::Base

  scope :ransacked, -> (search_params, forcer=nil) { ransack(search_params).result }
  scope :ordered, -> (order_value) { order(order_value) }

  self.abstract_class = true

  # belongs_to :created_by, class_name: "User", optional: true
  # belongs_to :updated_by, class_name: "User", optional: true

  def self.exists?(*args)
    HyperMeshExists.run(model: name, args: args)
  end if RUBY_ENGINE == 'opal'

  class HyperMeshExists < Hyperloop::ServerOp
    param acting_user: nil, allow_nils: true
    param :model
    param :args
    # TBD use policy system to insure we have permission to ask this question otherwise you are open to phishing attacks (?)
    step { Module.const_get(params.model).exists?(*params.args) }
	end

  def self.include_fields(params)
    if params[:fields] && params[:fields].is_a?(Array)
      h = {}
      params[:fields].each do |field|
        field_arr = field.split('.')
        build_node field_arr, h
      end
      result = includes(h)
    else
      result = self
    end
    result
  end

  def self.build_node arr, h
    current_node = arr.shift
    h[current_node.to_sym] ||= {}
    h[current_node.to_sym] = build_node arr, h[current_node.to_sym] if arr.size > 0
    h
  end

  def self.filter(params = {})
    params = {} if params.nil?

    limit = params[:limit].present? ? (params[:limit].to_i < 0 ? 0 : params[:limit].to_i > 1000 ? 1000 : params[:limit]) : ENV['DEFAULT_LIMIT'].to_i

    filter_base(params).limit(limit)
  end

  def self.total_elements(params = {})
    collection = filter(params).limit(nil).offset(nil)

    if collection.group_values.any?
      # cannot use query.distict.count() because of a bug that duplicates DISTINCTS and resolves to DISTINCT COUNT(DISTINCT ...) we do:
      value = collection.except(:select, :group, :distinct).count("#{collection.group_values.join(', ')}")
    else
      value = collection.count
    end
  end

  def self.filter_unsafe(params = {}, elastic = nil)
    params = {} if params.nil?
    result = filter_base(params)
    result = result.limit(params[:limit] || ENV['DEFAULT_LIMIT'].to_i) unless params[:limit] && params[:limit] == 'all'
    result
  end

  private

    def self.filter_base(params = {})
      base = include_fields(params).ransack(prepare_params(params)).result(distinct: params[:distinct])
      base = base.offset(params[:offset]) if params[:offset]
      base
    end

    def self.prepare_params(params)
      params = params.except(:controller, :action, :format)
      params["sorts"] = Array.wrap(params["sorts"]).map(&:underscore) if params["sorts"]
      params
    end
end
