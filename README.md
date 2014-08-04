# CrapServer
[![Code Climate](https://codeclimate.com/github/anga/crap_server/badges/gpa.svg)](https://codeclimate.com/github/anga/crap_server)

Really thin and non intuitive ruby server and framework. Made to be fast and ready for really heavy servers (not only http server).

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

## Configuring the app

    CrapServer::Application.configure do |config|
        config.port = 80
        config.read_method = :partial
        config.read_buffer_size = 1024 # 1K
    end

See all available options in lib/crap_server/configure.rb

# Running our application

ruby my_app.rb

# Production ready?

No. At the moment it's only a thin server that abstract you from TCP sockets works.

## Contributing

1. Fork it ( https://github.com/anga/crap_server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
