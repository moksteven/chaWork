migration 11, :add_field_to_bugs do
  up do
    modify_table :bugs do
      add_column :project_id, Integer
    end
  end

  down do
    modify_table :bugs do
      drop_column :project_id
    end
  end
end
