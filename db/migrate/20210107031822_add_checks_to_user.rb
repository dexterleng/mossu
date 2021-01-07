class AddChecksToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :checks, :user, index: true, foreign_key: true, null: false
  end
end
