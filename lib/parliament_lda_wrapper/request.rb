require_relative 'helpers/response_helper'
require_relative 'helpers/request_helper'

module ParliamentLdaWrapper
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
        response = Helpers::ResponseHelper.convert_to_json(make_request(@endpoint, options).body)

        break if response['result']['items'].count.zero?

        response_hash['result']['items'] += response['result']['items']
        options['_page'] += 1
      end

      response_hash
    end

    def get_by_ids(ids)
      raise ArgumentError.new('IDs cannot be nil or empty.') if ids.nil? or ids.empty?

      items = []
      ids.each do |id|
        response = Helpers::ResponseHelper.convert_to_json(make_request("resources/#{id}").body)
        items << response['result']['primaryTopic']
      end

      items
    end

    def make_request(endpoint, options={})
      Typhoeus::Request.new(
        Helpers::RequestHelper.full_uri(endpoint),
        params: options
      ).run
    end
  end
end
