require 'data_mapper'

module IrcLogger
  class Message
    include DataMapper::Resource

    property :id, Serial
    property :channel, String
    property :body, String
    property :timestamp, DateTime
  end
end

DataMapper.finalize
