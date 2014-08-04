migration 12, :create_tasks do
  up do
    create_table :tasks do
      column :id, Integer, :serial => true
      column :user_id, DataMapper::Property::Integer
      column :title, DataMapper::Property::String, :length => 255
      column :created_at, DataMapper::Property::DateTime
      column :status, DataMapper::Property::Integer
      column :tags, DataMapper::Property::String, :length => 255
      column :project_id, DataMapper::Property::Integer
      column :assign, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :tasks
  end
end
