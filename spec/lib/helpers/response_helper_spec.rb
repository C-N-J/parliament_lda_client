require 'spec_helper'

RSpec.describe ParliamentLdaClient::Helpers::ResponseHelper do
  let(:raw_research_briefings_request){ ParliamentLdaClient::Request.new('researchbriefings').make_request('researchbriefings' ,'min-date': '2017-01-01', 'max-date': '2017-01-10') }
  let(:research_briefings_request){ ParliamentLdaClient::Request.new('researchbriefings').get({ 'min-date': '2017-01-01', 'max-date': '2017-03-20' }) }
  let(:items){ research_briefings_request['result']['items'] }

  context '#convert_to_json' do
    it 'will convert hash to JSON' do
      VCR.use_cassette('helpers/response_helper/convert_to_json/returns_json') do
        expect(described_class.convert_to_json(raw_research_briefings_request.body).class).to eq(Hash)
      end
    end
  end

  context '#strip_ids' do
    it 'will return all the IDs' do
      VCR.use_cassette('helpers/response_helper/strip_ids/returns_ids') do
        expect(described_class.strip_ids(items).class).to eq(Array)
        expect(described_class.strip_ids(items).count).to eq(256)
        expect(described_class.strip_ids(items).first).to eq('710745')
      end
    end
  end

  context '#map_field_from_items' do
    it 'will return the requested field' do
      VCR.use_cassette('helpers/response_helper/map_field_from_items/return_the_requested_field') do
        expect(described_class.map_field_from_items(items, 'title').class).to eq(Array)
        expect(described_class.map_field_from_items(items, 'title').count).to eq(256)
        expect(described_class.map_field_from_items(items, 'title').first).to eq('UN International Day for the Elimination of Racial Discrimination')
      end
    end
  end

  context '#group_fields_from_items' do
    it 'will return the requested field and a the count' do
      VCR.use_cassette('helpers/response_helper/group_fields_from_items/return_the_requested_fields_and_count') do
        expect(described_class.group_fields_from_items(items, 'title').class).to eq(Hash)
        expect(described_class.group_fields_from_items(items, 'title').count).to eq(254)
        expect(described_class.group_fields_from_items(items, 'title').first).to eq(['UN International Day for the Elimination of Racial Discrimination', 1])
      end
    end
  end

  context 'group_items_by_time_period' do
    it 'will return items grouped by date' do
      VCR.use_cassette('helpers/response_helper/group_items_by_time_period/return_the_grouped_fields_and_count') do
        expect(described_class.group_items_by_time_period(items, :cweek).class).to eq(Array)
        expect(described_class.group_items_by_time_period(items, :cweek).count).to eq(11)
        expect(described_class.group_items_by_time_period(items, :cweek).first).to eq([11, 30])
      end
    end
  end
end
