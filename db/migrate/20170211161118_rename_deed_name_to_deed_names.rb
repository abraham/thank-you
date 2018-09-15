# frozen_string_literal: true

class RenameDeedNameToDeedNames < ActiveRecord::Migration[5.1]
  def change
    rename_column :deeds, :name, :names
  end
end
