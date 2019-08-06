module VariableClassNames

	def self.included(base)
		base.param className: nil, nils: true
	end

	def classes
		computed = defined?(self.class::CLASSES) && self.class::CLASSES || ''

		unless params.className.nil?
			computed = _recurring_classes_parse computed, params.className
		end

		# puts "computed"
		# puts computed

		computed
	end

	def _recurring_classes_parse memory, elements

		if elements.is_a? String
			memory += " #{elements}"

		elsif elements.is_a? Hash
			elements.each do |class_name, condition|
				memory += " #{class_name}" if condition
			end

		elsif elements.is_a? Array
			# puts "memory", memory

			elements.each do |element|
				# puts "element", element

				if element.is_a? String
					memory += " #{element}"

				elsif element.is_a?(Array) || element.is_a?(Hash)
					memory = _recurring_classes_parse memory, element
				end
			end
		end

		memory
	end

end