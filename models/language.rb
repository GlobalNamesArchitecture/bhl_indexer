class Language < ActiveRecord::Base

  def self.populate
    sql = "LOAD DATA INFILE '#{File.join(BHLIndexer::Config.root_path, 'db', 'BHLItemLanguage.csv')}' INTO TABLE languages FIELDS TERMINATED BY ',' (internet_archive_id, name)"
    ActiveRecord::Base.connection.execute sql
  end

end