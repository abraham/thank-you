class CreateLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :links, id: :uuid do |t|
      t.string :url, null: false
      t.string :text, null: false
      t.references :thank, foreign_key: true, type: :uuid, null: false
      t.references :user, foreign_key: true, type: :uuid, null: false

      t.timestamps
    end
  end
end
