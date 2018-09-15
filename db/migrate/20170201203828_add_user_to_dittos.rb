# frozen_string_literal: true

class AddUserToDittos < ActiveRecord::Migration[5.1]
  def change
    add_reference :dittos, :user, foreign_key: true, type: :uuid, null: false
  end
end
