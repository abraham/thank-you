class RenameDeedNameToDeedNames < ActiveRecord::Migration[5.1]
  def change
    rename_column :deeds, :name, :names
  end
end
