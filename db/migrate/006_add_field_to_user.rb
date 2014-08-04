migration 6, :add_field_to_user do
  up do
    modify_table :users do
      add_column :crypted_password, String
    end
  end

  down do
    modify_table :users do
      drop_column :crypted_password
    end
  end
end
