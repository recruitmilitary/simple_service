module SimpleService
  class Context < Hash
    include Hashie::Extensions::MergeInitializer
    include Hashie::Extensions::MethodAccess
    include Hashie::Extensions::IndifferentAccess

    attr_accessor :current_action
    attr_reader :failure_code, :status_key

    def initialize(ctx={}, success=true)
      @current_action = nil
      @fail_hard = false
      @message = nil
      @status_key = nil
      @failure_code = nil
      @success = success
      @skip_remaining = false
      @called_actions = []
      super ctx
    end

    # Builds a new context if the passed in data is a hash. If the passed in 
    # data is already a Context, it will be returned as is.
    def self.build(ctx = {})
      Context===ctx ? ctx : new(ctx)
    end

    # Adds a called action and its return value to the list of called actions 
    # for this context.
    def __add_called_action(action, ret)
      @called_actions << [action, ret]
    end

    # A list of the actions called by this context with their return values in 
    # the order they were called.
    def called_actions
      @called_actions
    end

    # Sets the context state to failed. If the context is set to fail hard, a 
    # SimpleService::Failure error will be raised containing the current 
    # context.
    def fail!(msg = nil, code = nil)
      @message = get_message(msg, :failure)
      @status_key = msg if msg.is_a?(Symbol)
      @failure_code = code
      @success = false
      raise SimpleService::Failure.new(self) if @fail_hard
    end

    # Set the context to raise SimpleService::Failure error if execution fails.
    def fail_hard!
      @fail_hard = true
    end

    # Returns true if the context is set to raise an error on failure, otherwise 
    # false.
    def fail_hard?
      @fail_hard
    end

    # Sets the context to fail without raising an error. This is the default for 
    # the context.
    def fail_soft!
      @fail_hard = false
    end

    # Returns true if action execution failed, otherwise false
    def failed?
      !success?
    end

    def inspect
      ins = "#<#{self.class}"
      ins << " @success=#{@success}"
      ins << " @message=#{@message}"
      ins << " @fail_hard=#{@fail_hard}"
      ins << " @skip_remaining=#{@skip_remaining}"
      ins << " @called_actions=#{@called_actions.inspect}"
      keys.sort_by(&:to_s).each do |key|
        ins << " #{key}=#{self[key].inspect}"
      end
      ins << '>'
      ins
    end

    # Returns the failure message
    def message
      @message
    end

    # Returns true if the remaining actions using this context should be 
    # skipped, otherwise false.
    def skip_remaining?
      @skip_remaining
    end

    # Set all remaining actions using this context to be skipped.
    def skip_remaining!
      @skip_remaining = true
    end

    # Returns true if no further actions should be processed using this context, 
    # otherwise false. This occurs if `skip_remaining?` is true, or the context 
    # is set to failed.
    def stop_processing?
      failed? || skip_remaining?
    end

    # Returns true if the context was successful, otherwise false.
    def success?
      @success
    end

    # Set the context status to successful.
    def success!(msg = nil)
      @message = get_message(msg, :success)
      @status_key = msg if msg.is_a?(Symbol)
      @failure_code = nil
      @success = true
    end

    def to_s
      inspect
    end

    private
    def i18n_scope
      class_name = underscore(current_action.class.name)
      "actions.#{class_name}"
    end

    def translate(sym, type, options = {})
      key = "#{i18n_scope}.#{sym}"
      defaults = [
        :"actions.#{sym}",
        :"#{i18n_scope}.#{type}",
        :"actions.#{type}"
      ]
      options[:default] = defaults

      SimpleService::Configuration.i18n.translate(key, options)
    end

    def get_message(msg, type)
      if msg.is_a?(Symbol)
        translate(msg, type)
      else
        msg
      end
    end

    # Not going to bring in ActiveSupport
    def underscore(str)
      str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
