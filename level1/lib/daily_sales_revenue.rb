require 'date'

class DailySalesRevenue
  class << self
    def run input
      return new(input).run
    end

    def to_cent floating_point_price
      (floating_point_price * 100).round
    end

    def from_cent cent_price
      cent_price / 100.0
    end
  end

  BASE_PRICE = to_cent 0.10
  PER_ADDITIONAL_PAGE = to_cent 0.07
  COLOR_MODE_PRICE = to_cent 0.18
  EXPRESS_DELIVERY_PRICE = to_cent 0.60

  def run
    return { totals: totals }
  end

  def initialize input
    @communications = input['communications'] || []
    @express_delivery = express_delivery input
  end

  def express_delivery input
    Hash[
      (input['practitioners'] || [])
        .map { |p| [ p['id'], p['express_delivery'] ] }
    ]
  end

  def totals
    @communications
      .group_by { |c| Date.parse(c['sent_at']) }
      .map do |sent_at, communications|
        {
          sent_on: sent_at,
          total: self.class.from_cent(days_total(communications))
        }
      end
      .sort_by { |s| s[:sent_on] }
  end

  def days_total communications
    communications.inject(0) do |sum, communication|
      sum + communication_price(communication)
    end
  end

  def communication_price communication
    [
      BASE_PRICE,
      additional_pages_price(communication),
      color_mode_price(communication),
      express_delivery_price(communication)
    ].sum
  end

  def additional_pages_price communication
    PER_ADDITIONAL_PAGE * (communication['pages_number'] - 1)
  end

  def color_mode_price communication
    return 0 unless communication['color']
    COLOR_MODE_PRICE
  end

  def express_delivery_price communication
    return 0 unless express_delivery? communication
    EXPRESS_DELIVERY_PRICE
  end

  def express_delivery? communication
    @express_delivery[communication['practitioner_id']]
  end
end
