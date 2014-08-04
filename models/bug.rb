class Bug
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :title, Text
  property :description, Text
  property :status, Integer, :default => 0 #status(int, 状态，0表示待跟进，1表示正在跟进，2表示已处理，3表示关闭）
  property :level, Integer, :default => 0 #level(int，优先级，0表示紧急，1表示重要，2表示一般)
  property :created_at, DateTime
  property :solve_user_id, Integer
  property :result, Text
  property :project_id, Integer

            

  belongs_to :project
  belongs_to :user,       :model => 'User', :child_key => 'user_id'
  belongs_to :solve_user, :model => 'User', :child_key => 'solve_user_id'

  before :save ,:default_value

  def level_word
    %w(紧急 重要 一般)[level]
  end

  def status_word
    %w(待跟进 跟进中 已处理 关闭)[status]
  end

  def stylesheets
    %w(danger info success)[level]
  end

  def default_value
    solve_user_id = user_id if solve_user_id.nil?
  end

  def self.level_hash
    {0 => '紧急',1 => '重要',2 => '一般'}
  end

  def self.status_hash
    {0 => '待跟进',1 => '跟进中',2 => '已处理', 3 => '关闭'}

  end


end
