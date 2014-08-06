# CrapServer
[![Gem Version](https://badge.fury.io/rb/crap_server.svg)](http://badge.fury.io/rb/crap_server)
[![Code Climate](https://codeclimate.com/github/anga/crap_server/badges/gpa.svg)](https://codeclimate.com/github/anga/crap_server)

Really thin and non intuitive ruby server. Made to be fast and ready for really heavy servers (not only http server).
Use Preforking and Evented pattern.

# Another one?

Yes. Why? because 2 main reasons. First, this is not a HTTP Web server, this is a generic server that can be used for any kind of TCP Socket server.
Second and most important, because is funny :)

## Installation

Add this line to your application's Gemfile:

    gem 'crap_server'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crap_server

## Basic Usage

    CrapServer::Application.run! do |data|
        if data =~ /^GET/
            write "Hello world"
        elsif data =~ /^SET/
            write "Setting value"
        else
            write "Something is wrong"
        end
    end

See all available options in lib/crap_server/configure.rb

# Running our application

ruby my_app.rb

# Production ready?

No. Use it under your own risk. Right now, the interface can change.

## Contributing

1. Fork it ( https://github.com/anga/crap_server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
