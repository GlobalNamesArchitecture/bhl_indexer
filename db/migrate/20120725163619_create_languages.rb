class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string  :internet_archive_id
      t.string  :name
    end
    add_index :languages, :internet_archive_id, :unique => true
  end
end
    