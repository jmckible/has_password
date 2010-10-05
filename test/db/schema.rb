ActiveRecord::Schema.define(:version=>0) do
  create_table :people, :force=>true do |t|
    t.string :email, :password_hash, :password_salt, :password_reset_token
    t.boolean :force_change_password, :default=>false
  end
end