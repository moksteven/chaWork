migration 9, :add_field_to_projects do
  up do
    modify_table :projects do
      add_column :user_id, Integer
    
    end
  end

  down do
    modify_table :projects do
      drop_column :user_id
    end
  end
end
