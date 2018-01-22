class CreateCasEnrollments < ActiveRecord::Migration
  def change
    create_table :cas_enrollments do |t|
      t.references :client, index: true
      t.references :enrollment, index: true
      t.date :entry_date
      t.date :exit_date
      t.timestamps null: false
      t.json :history
    end
  end
end
