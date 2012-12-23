require 'sinatra/base'
require 'ponder'
require 'data_mapper'
require 'irc_logger/message'
require 'haml'
require 'eventmachine'

module IrcLogger
  class Viewer < Sinatra::Base
    configure :development do
      require 'pry'
      require 'dm-sqlite-adapter'
      DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/mydatabase.db")
      # require 'sinatra/contrib'
      # register Sinatra::Reloader
    end

    configure :production do
      require 'dm-postgres-adapter'
      DataMapper.setup(:default, ENV['DATABASE_URL'])
    end

    configure do
      # DataMapper.auto_migrate!
      DataMapper.auto_upgrade!

      set :channels, {'ruby-lang' => ::EM::Channel.new}

      set :thaum, (Ponder::Thaum.new do |config|
        config.nick     = 'LogPonder'
        config.username = 'LogPonder'
      end)

      settings.thaum.tap do |thaum|
        thaum.on :connect do
          thaum.join '#ruby-lang'
        end

        thaum.on :channel, // do |event_data|
          channel = event_data[:channel].gsub('#', '')
          Message.create(:channel => channel, :body => "&#60;#{event_data[:nick]}&#62; #{event_data[:message]}", :timestamp => DateTime.now)
          settings.channels[channel].push("#{DateTime.now.strftime('%H:%M:%S')} &#60;#{event_data[:nick]}&#62; #{event_data[:message]}")
        end

        EM.next_tick { thaum.connect }
      end
    end

    get '/channels/:channel' do
      @messages = Message.all(:channel => params[:channel])
      haml :channel
    end

    get '/stream/:channel', provides: 'text/event-stream' do
      channel = settings.channels[params[:channel]]
      if channel
        stream :keep_open do |out|
          subscriber_id = channel.subscribe do |msg|
            out << "data: #{msg}\n\n"
          end

          proc = proc { channel.unsubscribe(subscriber_id) }
          out.callback(&proc)
          out.errback(&proc)
        end
      end
    end

    get '/pry' do
      binding.pry
      Message.all(:channel => 'ruby-lang').map(&:body).join('<br>')
    end
  end
end
