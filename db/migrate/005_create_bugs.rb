migration 5, :create_bugs do
  up do
    create_table :bugs do
      column :id, Integer, :serial => true
      column :user_id, DataMapper::Property::Integer
      column :title, DataMapper::Property::Text
      column :description, DataMapper::Property::Text
      column :status, DataMapper::Property::Integer
      column :level, DataMapper::Property::Integer
      column :created_at, DataMapper::Property::DateTime
      column :solve_user_id, DataMapper::Property::Integer
      column :result, DataMapper::Property::Text
    end
  end

  down do
    drop_table :bugs
  end
end
