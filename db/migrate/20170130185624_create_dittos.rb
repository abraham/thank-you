class CreateDittos < ActiveRecord::Migration[5.1]
  def change
    create_table :dittos, id: :uuid do |t|
      t.text :text, null: false
      t.references :thank, type: :uuid, null: false
      t.string :status_id, null: false

      t.timestamps
    end
  end
end
