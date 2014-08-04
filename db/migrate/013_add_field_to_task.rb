migration 13, :add_field_to_task do
  up do
    modify_table :tasks do
      add_column :level, DataMapper::Property::Integer
      add_column :deadline, DataMapper::Property::Date
    end
  end

  down do
    modify_table :tasks do
      drop_column :level
      drop_column :deadline
    end
  end
end
