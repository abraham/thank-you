class CreateThanks < ActiveRecord::Migration[5.1]
  def change
    create_table :thanks, id: :uuid do |t|
      t.string :text, null: false
      t.string :status_id, null: false

      t.timestamps
    end
  end
end
