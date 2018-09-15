# frozen_string_literal: true

class CreateThanks < ActiveRecord::Migration[5.1]
  def change
    create_table :thanks, id: :uuid do |t|
      t.string :text, null: false
      t.string :in_reply_to_status_id

      t.timestamps
    end
  end
end
