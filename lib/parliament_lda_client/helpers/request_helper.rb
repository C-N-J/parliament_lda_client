require_relative '../request'

module ParliamentLdaClient
  module Helpers
    module RequestHelper
      class << self
        def full_uri(endpoint)
          URI("#{Request::BASE_URL + endpoint + Request::DATA_FORMAT}")
        end
      end
    end
  end
end
