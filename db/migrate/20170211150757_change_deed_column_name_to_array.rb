# frozen_string_literal: true

class ChangeDeedColumnNameToArray < ActiveRecord::Migration[5.1]
  def change
    change_column :deeds, :name, :text, array: true, null: false, using: "(string_to_array(name, ','))"
  end
end
