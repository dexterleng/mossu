class AddSubmissionFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :submissions, :checks, column: :check_id, primary_key: 'id'
  end
end
