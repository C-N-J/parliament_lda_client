require 'spec_helper'

RSpec.describe ParliamentLdaWrapper::Request do
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

      context 'ID does not exist' do
        let(:ids){ ['abc'] }
        it 'is a pending example: will not return a result'
          #VCR.use_cassette('request/get_by_ids/invalid_ids/id_does_not_exist') 
          #end
        #end
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

    context 'invalid request' do
      it 'will return the correct exception'
    end
  end
end
