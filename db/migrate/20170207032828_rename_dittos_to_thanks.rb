# frozen_string_literal: true

class RenameDittosToThanks < ActiveRecord::Migration[5.1]
  def change
    rename_table :dittos, :thanks
    rename_column :deeds, :dittos_count, :thanks_count
    rename_column :users, :dittos_count, :thanks_count
  end
end
