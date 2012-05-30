class CreateNameStringResolutions < ActiveRecord::Migration
  def up
    create_table :name_string_resolutions do |t|
      t.text :resolution, :limit => 16_777_215
      t.timestamps
    end
  end

  def down
    drop_table :name_string_resolutions
  end
end
    
