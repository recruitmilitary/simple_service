module SimpleService
  module Action
    def self.included(base_class)
      base_class.class_eval do
        extend ClassMethods

        attr_reader :context
        attr_writer :logger
      end
    end

    module ClassMethods
      def accepted_keys
        @__accepted_keys ||= {}
      end

      def accepts(key, opts = {})
        accepted_keys[key] = opts
        define_context_accessors(key) if SimpleService::Configuration.define_context_accessors
      end

      def expected_keys
        @__expected_keys ||= []
      end

      # One of more symbols indicating the keys that must exist in the context 
      # for the action to be usable.
      def expects(*args)
        expected_keys.concat(args)
        define_context_accessors(*args) if SimpleService::Configuration.define_context_accessors
      end

      def promised_keys
        @__promised_keys ||= []
      end

      # One of more symbols indicating the keys the action promises to set in 
      # the context.
      def promises(*args)
        promised_keys.concat(args)
        #define_context_accessors(*args)
      end

      # Initializes and immediately runs the action. 
      #
      # Returns the context.
      def call(context = {})
        new(context).call
      end

      # Initializes and immediately runs the action. If the action fails, a 
      # SimpleService::Failure error will be raised.
      #
      # Returns the context if the action does not fail.
      def call!(context = {})
        new(context).call!
      end

      private

      # The usability of this is debatable since writers have to have a receiver 
      # when they're called. So might as well just use `context`. Just having 
      # readers, which really can't be updated may just lead to confusion. Maybe 
      # leave this as a user option.
      def define_context_accessors(*args)
        args.each do |key|
          define_method(key) do
            context.fetch(key)
          end

          #define_method("#{key}=") do |val|
            #context[key] = val
          #end
        end
      end
    end

    # Initializes the action with the passed in context data. If the data is a 
    # Hash, it will automatically be converted to a SimpleService::Context.
    def initialize(context = {})
      @context = Context.build(context)
      Context::KeyEnsurer.assign_accepted(@context, self)
    end

    # Runs the action according to the options given to the context on 
    # initialization.
    #
    # Returns the context
    def call
      return context if context.stop_processing?

      Context::KeyEnsurer.ensure_expected!(context, self)
      context.current_action = self

      ret = execute
      context.__add_called_action(self, ret)
      Context::KeyEnsurer.ensure_promised!(context, self) unless context.failed?
      context
    end

    # Forces a SimpleService::Failure to be raised if the action fails, and runs 
    # the action.
    #
    # Returns the context if the action does not fail
    def call!
      context.fail_hard!
      call
    end

    # Runs the action. This method must be overridden on the implementing 
    # class.
    def execute
    end

    # Shortcut to the logger to use for the action. Defaults to the logger 
    # defined in SimpleService::Configuration
    def logger
      @logger ||= SimpleService::Configuration.logger
    end
  end
end
