#!/usr/bin/env ruby

$: << File.expand_path('../../../lib', __FILE__)
require 'concurrent-edge'
require 'time'

Channel = Concurrent::Channel

def go(prc, *args)
  Channel::Runtime.go(prc, *args)
end

## Go by Example: Rate Limiting
# https://gobyexample.com/rate-limiting

requests = Channel.new(5)
(1..5).each do |i|
  requests << i
end
requests.close

limiter = Channel::Ticker.tick(0.2)

requests.each do |req|
  print "request #{req} #{Time.now}\n" if limiter.recv
end
print "\n"

bursty_limiter = Channel.new(3)
(1..3).each do
  bursty_limiter << Time.now
end

ticker = Channel::Ticker.tick(0.2)

go(lambda do
  ticker.each do |t|
    bursty_limiter << t
  end
end)

bursty_requests = Channel.new(5)
(1..5).each do |i|
  bursty_requests << i
end
bursty_requests.close

bursty_requests.each do |req|
  bursty_limiter.recv
  print "request #{req} #{Time.now}\n"
end

limiter.close
ticker.close

__END__
request 1 2012-10-19 00:38:18.687438 +0000 UTC
request 2 2012-10-19 00:38:18.887471 +0000 UTC
request 3 2012-10-19 00:38:19.087238 +0000 UTC
request 4 2012-10-19 00:38:19.287338 +0000 UTC
request 5 2012-10-19 00:38:19.487331 +0000 UTC

request 1 2012-10-19 00:38:20.487578 +0000 UTC
request 2 2012-10-19 00:38:20.487645 +0000 UTC
request 3 2012-10-19 00:38:20.487676 +0000 UTC
request 4 2012-10-19 00:38:20.687483 +0000 UTC
request 5 2012-10-19 00:38:20.887542 +0000 UTC
