require 'date'

class DailySalesRevenue
  BASE_PRICE = 0.10
  PER_ADDITIONAL_PAGE = 0.07

  class << self
    def run input
      return {totals: totals(input)}
    end

    def totals input
      communications_of(input)
        .group_by { |c| Date.parse(c['sent_at']) }
        .map do |sent_at, communications|
          {
            sent_on: sent_at,
            total: days_total(communications)
          }
        end
        .sort_by { |s| s[:sent_on] }
    end

    def communications_of input
      input['communications'] || []
    end

    def days_total communications
      communications.inject(0) do |sum, communication|
        sum + communication_price(communication)
      end
    end

    def communication_price communication
      communication_price = BASE_PRICE + additional_pages_price(communication)
    end

    def additional_pages_price communication
      PER_ADDITIONAL_PAGE * (communication['pages_number'] - 1)
    end
  end
end
