require 'rubygems'
require 'excon'
Excon.ssl_verify_peer = Rails.env.production?