require 'dm-core'
require 'dm-migrations'

class Entry
  include DataMapper::Resource

  property :id, Serial
  property :subject, String, :length => 255, :required => true
  property :entry, Text
  property :created_at, DateTime
  property :updated_at, DateTime
end
