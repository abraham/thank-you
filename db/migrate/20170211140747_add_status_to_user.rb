# frozen_string_literal: true

class AddStatusToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :status, :integer, null: false, default: 0
  end
end
