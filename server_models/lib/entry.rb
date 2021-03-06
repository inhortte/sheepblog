require 'dm-core'
require 'dm-migrations'

class Entry
  include DataMapper::Resource

  property :id, Serial
  property :subject, String, :length => 255, :required => true
  property :entry, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :topics, :through => Resource
end

class Topic
  include DataMapper::Resource

  property :id, Serial
  property :topic, String, :length => 255, :required => true, :unique => true
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :entries, :through => Resource
end
