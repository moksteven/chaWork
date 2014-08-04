class Report
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :today, Text
  property :tomorrow, Text
  property :summary, Text
  property :wdate, DateTime
  property :created_at, DateTime

  belongs_to :user

  def self.wrap content
    arr = content.split("\r\n")
    arr = arr.join('<br />')
    arr
  end

  def data_format 
    created_at.strftime('%Y-%m-%d')
  end
end
