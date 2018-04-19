require 'spec_helper'

RSpec.describe ParliamentLdaClient::Helpers::RequestHelper do
  context '#full_uri' do
    context 'valid request' do
      it 'will return a correctly generated URI' do
        VCR.use_cassette('helpers/request_helper/full_uri/valid_request/return_correct_uri') do
          expect(described_class.full_uri('test-endpoint').to_s).to eq('http://lda.data.parliament.uk/test-endpoint.json')
        end
      end
    end
  end
end
