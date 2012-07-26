class AddLanguageToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :language, :string
  end
end
    