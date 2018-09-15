# frozen_string_literal: true

class AddDittosCountToThanks < ActiveRecord::Migration[5.1]
  def change
    add_column :thanks, :dittos_count, :integer, null: false, default: 0
  end
end
