APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../../"))
require 'bundler/setup'

require 'sinatra/base'
require 'erb'
require 'benchmark'
require 'thread'

require 'redis'

require File.join(File.dirname(__FILE__), 'models/bid_queue')
require File.join(File.dirname(__FILE__), 'models/bid_worker')
require File.join(File.dirname(__FILE__), 'models/top_bids')

# globally available across all threads for stats
$redis = Redis.new(:host => 'localhost', :port => 6379)
$bid_queue = BidQueue.new
$top_bids = TopBids.new
# rubys built in mutex runs *much* faster than a network mutex so needs to be globally available across all threads
$mutex = Mutex.new

module AuctionEngine
  class App < Sinatra::Base
    
    set :views, File.dirname(__FILE__) + '/views'
    
    get "/" do
      erb :index
    end

    post "/bids" do
      bid = JSON.parse request.body.read
      $bid_queue.add_bid(
                  {
                      :user => bid.user,
                      :amount => bid.amount
                  })
    end

    # Ugly way to run BidWorker pool as a daemon
    (1..10).each do |t|
      Thread.new do
        BidWorker.new.do_loop
      end
    end
  end
end
