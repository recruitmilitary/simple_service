module SimpleService
  class Context
    class KeyEnsurer
      class << self
        def ensure_expected!(context, action)
          ensure_keys(context, action, action.class.expected_keys, MissingExpectedKeys)
        end

        def ensure_promised!(context, action)
          ensure_keys(context, action, action.class.promised_keys, MissingPromisedKeys)
        end

        def assign_accepted(context, action)
          action.class.accepted_keys.each do |key, options|
            next if context.include? key
            default = options[:default]
            context[key] = default.respond_to?(:call) ? default.call : default
          end
        end

        private
        def ensure_keys(context, action, required_keys, error)
          missing_keys = stringify_keys(required_keys) - context.keys
          raise error.new(context, action, missing_keys) unless missing_keys.empty?
        end

        def stringify_keys(keys)
          keys.map(&:to_s)
        end
      end
    end
  end
end
