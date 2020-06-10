module Rapyd

  require "rapyd/version"

  require "rapyd/api_resource"
  require "rapyd/api_request"

  require 'rapyd/rapyd_error'

  class << self
    attr_accessor :mode,
      :secret_key,
      :access_key

    def api_base
      live_url = "https://api.rapyd.net"
      test_url = "https://sandboxapi.rapyd.net"
      @api_base ||= mode == "live" ? live_url : test_url
    end
  end

end