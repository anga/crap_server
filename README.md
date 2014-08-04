# CrapServer

Really thin a non intuitive ruby server and framework. Made to be fast and ready for really heavy servers (not only http server).

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

No. At the moment is only a thin server that abstract you from TCP sockets works.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/crap_server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
