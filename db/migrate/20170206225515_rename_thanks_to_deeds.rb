# frozen_string_literal: true

class RenameThanksToDeeds < ActiveRecord::Migration[5.1]
  def change
    rename_table :thanks, :deeds
    rename_column :dittos, :thank_id, :deed_id
    rename_column :links, :thank_id, :deed_id
    rename_column :users, :thanks_count, :deeds_count
  end
end
