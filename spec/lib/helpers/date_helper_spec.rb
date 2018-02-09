require 'spec_helper'

RSpec.describe ParliamentLdaWrapper::Helpers::DateHelper do
  let(:research_briefings_request){ ParliamentLdaWrapper::Request.new('researchbriefings').get({ 'min-date': '2017-01-01', 'max-date': '2017-03-20' }) }
  let(:items){ research_briefings_request['result']['items'] }

  context '#strip_date' do
    it 'will return the correct date' do
      VCR.use_cassette('helpers/date_helper/strip_date/returns_to_correct_date') do
        expect(described_class.strip_date(items.first)).to eq('2017-03-17')
      end
    end
  end
end
