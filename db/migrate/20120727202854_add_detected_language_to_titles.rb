class AddDetectedLanguageToTitles < ActiveRecord::Migration
  def change 
    add_column :titles, :english, :boolean
  end
end
    
