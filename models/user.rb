class User
  include DataMapper::Resource
  include DataMapper::Validate
  attr_accessor :password, :password_confirmation

  # property <name>, <type>
  property :id, Serial
  property :email, String
  property :name, String
  # property :password, String
  property :login_count, Integer, :default => 0
  property :last_login, DateTime
  property :photo, String, :auto_validation => false
  property :title, String
  property :created_at, DateTime

  property :crypted_password, String

  mount_uploader :photo, AvatarUploader

  # Callbacks
  before :save, :encrypt_password

  has n, :projects, :constraint => :destroy
  has n, :bugs,     :constraint => :destroy
  has n, :reports

  # This method is for authentication purpose.
  #
  def self.authenticate(email, password)
    account = first(:conditions => ["lower(email) = lower(?)", email]) if email.present?
    account && account.has_password?(password) ? account : nil
  end

  ##
  # This method is used by AuthenticationHelper
  #
  def self.find_by_id(id)
    get(id) rescue nil
  end

  # 头像URL
  def avatar_url
    url = photo.thumb.url.to_s.empty? ? '' : ConfigDb::URL + photo.thumb.url.to_s 
  end

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  private

  def password_required
    crypted_password.blank? || password.present?
  end

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end

end
