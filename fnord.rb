#!/usr/bin/env ruby

require 'fnordmetric'

FnordMetric.namespace :cat_faucet do
  hide_overview
  hide_active_users
  hide_gauge_explorer

  #gauge :events, :title => "Total Drinks"
  timeseries_gauge :number_of_drinks,
    :group => "Beaker Activity",
    :title => "Drink Count",
    #:key_nouns => ["Drinks", "Drink"],
    :series => [:drinks],
    :value_scale => 1.hour,
    :plot_style => :line,
    :tick => 1.day,
    :autoupdate => 1


  distribution_gauge :hour_activity,
    :group => "Beaker Activity",
    :title => "By Hour",
    # :value_ranges => (0..23).collect{|i| (i..i)},
    :precision => 0,
    :include_current => false,
    :autoupdate => 1,
    :value_scale => 1

  # important: this has to be after the distribution_gauge  :(
  gauge :hour_activity, :title => "Drinks by Hour"


  event :drink do
    puts "got event: #{data.inspect} "
    incr :number_of_drinks, :drinks, 1
    #incr :drinks, 1
    observe :hour_activity, data[:hour]
    incr :events_per_hour
  end


  gauge :events_per_hour, :tick => 1.hour
  widget 'TechStats', {
    :title => "Events per Hour",
    :group => "Stuff",
    :type => :timeline,
    :gauges => :events_per_hour,
    :include_current => true,
    :autoupdate => 1
  }


end

FnordMetric.options = {
  # all data that isn't processed within 10s is discarded to prevent memory overruns
  :event_queue_ttl  => 10,
  # event data is stored for one hour (needed for the active users view)
  :event_data_ttl   => 3600,
  # session data is stored for one hour (needed for the active users view)
  :session_data_ttl => 3600,
  :redis_prefix => "fnordmetric",
}

FnordMetric::Web.new(:port => 4242)
FnordMetric::Acceptor.new(:protocol => :tcp, :port => 2323)
FnordMetric::Worker.new
FnordMetric.run