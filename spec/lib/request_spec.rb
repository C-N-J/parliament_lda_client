require 'spec_helper'

RSpec.describe ParliamentLdaClient::Request do
  let(:endpoint_string) { 'researchbriefings' }
  let(:request_instance){ described_class.new(endpoint_string) }
  let(:options)                   { {'min-date': '2017-01-01', 'max-date': '2017-12-31'} }
  let(:research_briefings_request){ described_class.new(endpoint_string).get_data(options) }

  context '#initialize' do
    it 'will initialize the class' do
      expect(request_instance).to be_an_instance_of(described_class)
    end

    it 'will set endpoint' do
      expect(request_instance.instance_variable_get(:@endpoint)).to eq(endpoint_string)
    end
  end

  context '#get' do
    context 'research briefings' do
      let(:options)                   { {'min-date': '2017-01-01', 'max-date': '2017-12-31'} }
      let(:research_briefings_request){ described_class.new(endpoint_string).get(options) }

      it 'gets all the data' do
        VCR.use_cassette('request/get/get_all_research_briefings_data') do
          expect(research_briefings_request['result']['items'].count).to eq(1227)
        end
      end

      context 'different options' do
        let(:options){ {'min-date': '2017-01-01', 'max-date': '2017-06-29', 'exists-category': 'true' } }

        it 'will filter using different options' do
          VCR.use_cassette('request/get/get_different_options') do
            expect(research_briefings_request['result']['items'].count).to eq(94)
          end
        end
      end
    end

    context 'constituencies' do
      let(:endpoint_string)      { 'constituencies' }
      let(:options)              { {} }
      let(:constituencies_request){ described_class.new(endpoint_string).get(options) }

      it 'gets all the data' do
        VCR.use_cassette('request/get/get_all_constituencies_data') do
          expect(constituencies_request['result']['items']).to_not eq(nil)
        end
      end

      it 'gets valid data' do
        VCR.use_cassette('request/get/get_single_constituency') do
          expect(constituencies_request['result']['items'][0]['label']['_value']).to eq('Aberavon')
        end
      end
    end
  end

  context '#get_by_ids' do
    let(:ids_request){ described_class.new.get_by_ids(ids) }

    context 'multiple valid ids' do
      let(:ids){ ['143468', '143491', '824308'] }

      it 'will return valid data' do
        VCR.use_cassette('request/get_by_ids/multiple_valid_ids') do
          expect(ids_request.count).to eq(3)
          expect(ids_request[0]['label']['_value']).to eq('Aberdeen Central')
          expect(ids_request[1]['label']['_value']).to eq('Accrington')
          expect(ids_request[2]['identifier']['_value']).to eq('CBP-8033')
        end
      end
    end

    context 'single valid id' do
      let(:ids){ ['143468'] }
      it 'will return valid data' do
        VCR.use_cassette('request/get_by_ids/single_valid_id') do
          expect(ids_request.count).to eq(1)
          expect(ids_request[0]['label']['_value']).to eq('Aberdeen Central')
        end
      end
    end

    context 'invalid ids' do
      context 'no ID' do
        let(:ids){ [] }
        it 'will raise an error' do
          VCR.use_cassette('request/get_by_ids/invalid_ids/empty_array') do
            expect{ ids_request }.to raise_error(ArgumentError, 'IDs cannot be nil or empty.')
          end
        end
      end
    end
  end

  context '#make_request' do
    context 'valid request' do
      it 'will return the correct response' do
        VCR.use_cassette('request/make_request/valid_request/will_return_the_correct_result') do
          expect(request_instance.make_request('researchbriefings', {'min-date': '2017-01-01', 'max-date': '2017-01-10'}).code).to eq(200)
        end
      end
    end
  end

  context '#handle_errors' do
    # The required response codes have been added to the VCR cassettes to mock each scenario.
    let(:url){ 'www.example.com' }
    let(:response){ described_class.new(url).make_request(url) }

    context 'success' do
      it 'will not raise an error' do
        VCR.use_cassette('request/handle_errors/success/will_not_raise_error') do
          expect{ request_instance.handle_errors(response) }.to_not raise_error(StandardError)
        end
      end
    end

    context 'server error' do
      it 'will not raise an error' do
        VCR.use_cassette('request/handle_errors/server_error/will_raise_error') do
          expect{ request_instance.handle_errors(response) }.to raise_error(StandardError, '500 HTTP status code recieved from http://lda.data.parliament.uk:80/www.example.com.json - Server Error')
        end
      end
    end

    context 'client error' do
      it 'will not raise an error' do
        VCR.use_cassette('request/handle_errors/client_error/will_raise_error') do
          expect{ request_instance.handle_errors(response) }.to raise_error(StandardError, '400 HTTP status code recieved from http://lda.data.parliament.uk:80/www.example.com.json - Client Error')
        end
      end
    end
  end
end
