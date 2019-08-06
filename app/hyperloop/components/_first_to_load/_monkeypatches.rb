module ReactiveRecord
  class Broadcast

    def merge_current_values(br)
      # puts "\n\nMERGING!!!\n\n"
      current_values = Hash[*@previous_changes.collect do |attr, values|
        value = attr == :id ? record[:id] : values.first
        if br.attributes.key?(attr) &&
           br.attributes[attr] != br.convert(attr, value) &&
           br.attributes[attr] != br.convert(attr, values.last)
          puts "warning #{attr} has changed locally - will force a reload.\n"\
               "local value: #{br.attributes[attr]} remote value: #{br.convert(attr, value)}->#{br.convert(attr, values.last)}"
          return nil
        end
        [attr, value]
      end.compact.flatten(1)].merge(br.attributes)
      klass._react_param_conversion(current_values)
    end

  end
end