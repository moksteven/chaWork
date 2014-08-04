migration 8, :create_user_projects do
  up do
    create_table :user_projects do
      column :id, Integer, :serial => true
      column :project_id, DataMapper::Property::Integer
      column :user_id, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :user_projects
  end
end
