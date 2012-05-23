class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.references :title
      t.string  :name
      t.integer :offset_start
      t.integer :offset_end
      t.timestamps
    end
    add_index :pages, [:title_id, :offset_start]
  end
end
    
