module CmEmail
  class Configuration
    attr_accessor :api_key, :api_mode

    def initialize
      @api_key = nil
      @api_mode = 'production'
    end
  end
end