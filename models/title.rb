class Title < ActiveRecord::Base
  has_many :pages
  attr_accessor :gnrd_url, :names
  after_initialize :concatenate_pages

  STATUS = { init: 0, enqueued: 1, completed: 2, failed: 3 } 
  
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

  def send_text
    res = RestClient.post(BHLIndexer::Config.gnrd_api_url, :format => 'json', :text => concatenated_text, :engine => 0, :unique => false)
    res = JSON.parse(res, :symbolize_names => true)
    @gnrd_url = res[:url]
  end

  def get_names
    return unless @gnrd_url
    @names = JSON.parse(RestClient.get(@gnrd_url), :symbolize_names => true)[:names]
  end

  def make_pages
    return unless @names
  end

  def concatenated_text
    @concatenator.concatenated_text
  end

  def pages_offsets
    @concatenator.pages_offsets
  end

  def pages_ids
    @concatenator.pages_ids
  end

  private

  def concatenate_pages
    @gnrd_url = nil
    @concatenator = BHLIndexer::Concatenator.new(File.join(BHLIndexer::Config.root_file_path, path))
    @concatenator.concatenate
  end
end
