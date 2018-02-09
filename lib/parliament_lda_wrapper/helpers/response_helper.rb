require_relative 'date_helper'
require 'json'

module ParliamentLdaWrapper
  module Helpers
    module ResponseHelper
      class << self
        def convert_to_json(response)
          JSON.parse(response)
        end

        def strip_ids(items)
          items.map { |item| item['_about'].scan(/resources\/(\d+)/)[0][0] }
        end

        def map_field_from_items(response, field_name)
          field = response.map { |item| item[field_name] }
          field = field.compact
          field.flatten! if field.first.is_a?(Array)
          field
        end

        def group_fields_from_items(items, field_name)
          mapped_items = map_field_from_items(items, field_name)
          mapped_items.each_with_object(Hash.new(0)) { |field, counts| counts[field] += 1 }
        end

        def group_items_by_time_period(items, time_period_to_group_by)
          dates = []
          items.each { |item| dates << DateHelper.strip_date(item) }

          dates.map!{ |date| Date.parse(date) }

          grouped_dates = []
          dates.group_by(&time_period_to_group_by).each do |time_period, values|
            grouped_dates << [time_period, values.count]
          end

          grouped_dates
        end
      end
    end
  end
end
