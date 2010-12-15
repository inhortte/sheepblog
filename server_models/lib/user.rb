require 'dm-core'
require 'dm-migrations'
require 'digest'

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String, :required => true, :unique => true
  property :encrypted_password, String, :length => 255
  property :salt, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime

  attr_accessor :password, :password_confirmation

  validates_presence_of :password
  validates_presence_of :password_confirmation
  validates_length_of :password, :min => 5
  validates_confirmation_of :password

  def has_password?(passwd)
    self.encrypted_password == encrypt(passwd)
  end

  before :save, :encrypt_password

  private

  def encrypt_password
    self.salt = make_salt if new?
    self.encrypted_password = encrypt(self.password)
  end

  def encrypt(s)
    secure_hash("#{self.salt}--#{s}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{self.password}")
  end

  def secure_hash(s)
    Digest::SHA2.hexdigest(s)
  end
end
