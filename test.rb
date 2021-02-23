require "rubygems"
require "bundler"
Bundler.require

require "minitest/autorun"

require "async"
require "async/barrier"
require "async/http/internet"
require "kernel/sync"

VCR.configure do |config|
  config.cassette_library_dir = "fixtures"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = { :record => :none }
end

class Test < Minitest::Test
  # Transfer-Encoding header is in the VCR cassette, but not Content-Length, so
  # I expect this to succeed, but it fails with the following:
  # Protocol::HTTP1::BadRequest: Message contains both transfer encoding and content length!
  # Perhaps because I'm not (and don't know how to) build the request with
  # accept-encoding: gzip -- it looks like the async/protocol-http libs might
  # set the header internally?
  def test_bad_request
    VCR.use_cassette("dark_sky_1") do
      Sync do
        internet = Async::HTTP::Internet.new
        response = internet.get("https://api.darksky.net/forecast/abc123/47.76,-122.20")
        assert_match /Mostly cloudy/, response.read
      end
    end
  end

  # Remove the Transfer-Encoding header from the VCR cassette and it succeeds
  def test_ok_request
    VCR.use_cassette("dark_sky_2") do
      Sync do
        internet = Async::HTTP::Internet.new
        response = internet.get("https://api.darksky.net/forecast/abc123/47.76,-122.20")
        assert_match /Mostly cloudy/, response.read
      end
    end
  end
end
