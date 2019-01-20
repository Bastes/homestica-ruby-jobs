require "json"

require_relative 'lib/daily_sales_revenue'

puts JSON.pretty_generate(DailySalesRevenue.run(JSON.parse(STDIN.read)))
