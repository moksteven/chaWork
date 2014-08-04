migration 10, :add_field_to_users do
  up do
    modify_table :users do
      add_column :title, String
    end
  end

  down do
    modify_table :users do
      drop_column :title
    end
  end
end
