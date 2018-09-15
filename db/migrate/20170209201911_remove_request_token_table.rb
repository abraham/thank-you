# frozen_string_literal: true

class RemoveRequestTokenTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :request_tokens
  end
end
