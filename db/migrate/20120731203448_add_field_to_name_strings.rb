class AddFieldToNameStrings < ActiveRecord::Migration
  def change
    add_column :name_strings, :match_type, :string
    add_column :name_strings, :in_curated_source, :boolean
  end
end
    
