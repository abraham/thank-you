# frozen_string_literal: true

class AddDefaultAvatarToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :default_avatar, :boolean, default: true, null: false
  end
end
