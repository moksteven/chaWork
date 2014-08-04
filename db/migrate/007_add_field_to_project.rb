migration 7, :add_field_to_project do
  up do
    modify_table :projects do
      add_column :created_at, DateTime
    add_column :end_time, DateTime
    end
  end

  down do
    modify_table :projects do
      drop_column :created_at
    drop_column :end_time
    end
  end
end
