# frozen_string_literal: true

class CreateRequestTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :request_tokens, id: :uuid do |t|
      t.string :token, null: false
      t.string :secret, null: false

      t.timestamps
    end
  end
end
