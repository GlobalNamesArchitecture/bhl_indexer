class CreateTitles < ActiveRecord::Migration
  def change
    create_table :titles do |t|
      t.string  :path
      t.string  :internet_archive_id
      t.integer :status, :default => 0
      t.timestamps
    end
    add_index :titles, :internet_archive_id, :unique => true
    add_index :titles, :status
  end
end
    
