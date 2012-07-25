class Language < ActiveRecord::Base
  belongs_to :title, :foreign_key => "internet_archive_id"

  def self.populate
    sql = "LOAD DATA INFILE '#{File.join(BHLIndexer::Config.root_path, 'db', 'BHLItemLanguage.csv')}' INTO TABLE languages FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n' (internet_archive_id, name)"
    ActiveRecord::Base.connection.execute sql
  end

end