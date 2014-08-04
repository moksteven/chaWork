migration 2, :create_users do
  up do
    create_table :users do
      column :id, Integer, :serial => true
      column :email, DataMapper::Property::String, :length => 255
      column :name, DataMapper::Property::String, :length => 255
      # column :password, DataMapper::Property::String, :length => 255
      column :login_count, DataMapper::Property::Integer
      column :last_login, DataMapper::Property::DateTime
      column :photo, DataMapper::Property::String, :length => 255
      column :created_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :users
  end
end
