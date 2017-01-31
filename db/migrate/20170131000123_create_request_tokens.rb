class CreateRequestTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :request_tokens, id: :uuid do |t|
      t.string :request_token, null: false
      t.string :request_token_secret, null: false

      t.timestamps
    end
  end
end
