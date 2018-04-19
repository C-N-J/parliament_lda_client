require_relative 'helpers/response_helper'
require_relative 'helpers/request_helper'
require 'typhoeus'

module ParliamentLdaClient
  class Request
    BASE_URL        = 'http://lda.data.parliament.uk/'.freeze
    DATA_FORMAT     = '.json'.freeze
    DEFAULT_OPTIONS = { '_page' => 0, '_pageSize' => 500 }.freeze

    def initialize(endpoint=nil)
      @endpoint = endpoint
    end

    def get(options={})
      options = DEFAULT_OPTIONS.merge(options)

      response_hash = { 'result' => { 'items' => [] } }

      loop do
        response = make_request(@endpoint, options)

        handle_errors(response)

        response_body = Helpers::ResponseHelper.convert_to_json(response.body)

        break if response_body['result']['items'].count.zero?

        response_hash['result']['items'] += response_body['result']['items']
        options['_page'] += 1
      end

      response_hash
    end

    def get_by_ids(ids)
      raise ArgumentError.new('IDs cannot be nil or empty.') if ids.nil? or ids.empty?

      ids.map do |id|
        response = make_request("resources/#{id}")
        handle_errors(response)

        response_body = Helpers::ResponseHelper.convert_to_json(response.body)
        response_body['result']['primaryTopic']
      end
    end

    def make_request(endpoint, options={})
      Typhoeus::Request.new(
        Helpers::RequestHelper.full_uri(endpoint),
        params: options
      ).run
    end

    def handle_errors(response)
      if response.failure? || response.timed_out?
        raise StandardError.new("#{response.code} HTTP status code recieved from #{response.effective_url.to_s} - #{response.status_message}")
      end
    end
  end
end
