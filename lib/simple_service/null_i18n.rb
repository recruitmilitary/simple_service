module SimpleService
  class NullI18n
    def translate(msg, options = {})
      msg
    end
  end
end
