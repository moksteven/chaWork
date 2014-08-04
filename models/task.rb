class Task
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :title, String
  property :created_at, DateTime
  property :status, Integer, :default => 0
  property :tags, String
  property :project_id, Integer, :default => 0
  property :assign, Integer
  property :level, Integer, :default => 2
  property :deadline, Date

  belongs_to :project
  belongs_to :user
  delegate :name, :to => :user , :prefix => true, :allow_nil => true
  delegate :name, :to => :project , :prefix => true, :allow_nil => true

  belongs_to :solve_user, :model => 'User', :child_key => 'assign'
  
  def level_word
    %w(紧急 重要 一般)[level]
  end

  def status_word
    %w(待跟进 跟进中 已处理 关闭)[status]
  end

  def stylesheets
    %w(danger info success)[level]
  end

  def self.level_hash
    {0 => '紧急',1 => '重要',2 => '一般'}
  end

end
