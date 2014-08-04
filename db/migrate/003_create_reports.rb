migration 3, :create_reports do
  up do
    create_table :reports do
      column :id, Integer, :serial => true
      column :user_id, DataMapper::Property::Integer
      column :today, DataMapper::Property::Text
      column :tomorrow, DataMapper::Property::Text
      column :summary, DataMapper::Property::Text
      column :wdate, DataMapper::Property::DateTime
      column :created_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :reports
  end
end
