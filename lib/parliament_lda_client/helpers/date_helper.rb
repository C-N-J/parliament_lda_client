require 'date'

module ParliamentLdaClient
  module Helpers
   module DateHelper
     def self.strip_date(item)
       item['date']['_value'].scan(/\d{4}-\d{2}-\d{2}/).first
     end
   end
  end
end
