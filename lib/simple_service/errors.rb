module SimpleService
  class Failure < StandardError
    attr_reader :context

    def initialize(ctx = nil)
      @context = ctx
      super @context.message
    end
  end

  class KeyError < StandardError
    attr_reader :context, :action, :keys

    def initialize(ctx, action, keys, msg)
      @context = ctx
      @action = action
      @keys = keys
      super msg
    end

    private
    def format_keys(list)
      list.map{|k| ":#{k}"}.join(', ')
    end
  end

  class MissingExpectedKeys < KeyError
    def initialize(ctx, action, keys)
      msg = "#{action} did not find the expected key(s): #{format_keys(keys)}"
      super ctx, action, keys, msg
    end
  end

  class MissingPromisedKeys < KeyError
    def initialize(ctx, action, keys)
      msg = "#{action} did not set the promised key(s): #{format_keys(keys)}"
      super ctx, action, keys, msg
    end
  end
end
