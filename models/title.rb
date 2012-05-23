class Title < ActiveRecord::Base
  has_many :pages
  
  STATUS = {0 => 'entered', 1 => 'enqueued', 2 => 'success', 3 => 'failure'}
  
  def self.populate
    root_path = BHLIndexer::Config.root_file_path
    Dir.chdir(root_path)
    inside_title = false
    current_full_dir = nil
    current_internet_archive_id = nil
    Find.find(".").each do |f|
      if File.file?(f) && !inside_title
        inside_title = true
#        page = File.basename(f)
        current_full_dir = File.dirname(f)
        current_internet_archive_id = current_full_dir.split("/")[-1]
        Title.create(:path => current_full_dir, :internet_archive_id => current_internet_archive_id)
#      elsif File.file?(f) && inside_title
#        page = File.basename(f)
      elsif !File.file?(f) && inside_title
        inside_title = false
      end
    end
  end

end
