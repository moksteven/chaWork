class UserProject
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :project_id, Integer
  property :user_id, Integer

  belongs_to :user 
  belongs_to :project
end
