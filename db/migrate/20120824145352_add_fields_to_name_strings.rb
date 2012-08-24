class AddFieldsToNameStrings < ActiveRecord::Migration
  def up
    add_column :resolved_name_strings, :in_curated_sources, :boolean, :default => false
    add_column :resolved_name_strings, :finds_num, :integer
  end

  def down
    remove_column :resolved_name_strings, :finds_num
    remove_column :resolved_name_strings, :in_curated_sources
  end
end
    
