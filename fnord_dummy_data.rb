require 'em/pure_ruby'
require 'fnordmetric'

api = FnordMetric::API.new
10.times {
  api.event :_type => :drink, :hour => rand(24)
}
