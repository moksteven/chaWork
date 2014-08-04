class Project
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :description, String
  property :end_time, DateTime
  property :created_at, DateTime
  property :user_id,Integer

  belongs_to :user

  has n, :user_projects, :constraint => :destroy
  has n, :users, :through => :user_projects

  after :save, :join_project

  def join_project
  	UserProject.first_or_create(:user_id=>user_id,:project_id=>id)
  end

end
