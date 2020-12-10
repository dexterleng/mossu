class CreateChecks < ActiveRecord::Migration[6.0]
  def change
    create_table :checks do |t|
      t.string :name, null: false
      t.integer :status, null: false
      t.timestamps
    end
  end
end
