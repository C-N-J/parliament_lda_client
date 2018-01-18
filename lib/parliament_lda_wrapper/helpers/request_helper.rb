require_relative '../request'

module ParliamentLdaWrapper
  module Helpers
    module RequestHelper
      class << self
        def full_uri(endpoint, options)
          URI("#{Request::BASE_URL + endpoint + Request::DATA_FORMAT}?#{URI.encode_www_form(options) if options.any?}")
        end
      end
    end
  end
end
