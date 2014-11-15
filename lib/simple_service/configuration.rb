module SimpleService
  class Configuration
    class << self
      attr_accessor :logger
      attr_writer :i18n, :define_context_accessors

      def i18n
        @i18n ||= NullI18n
      end

      def define_context_accessors
        @define_context_accessors ||= false
      end

    end
  end
end
