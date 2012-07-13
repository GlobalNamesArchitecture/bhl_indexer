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
    current_title = nil
    Find.find(".").each do |f|
      if File.file?(f) && !inside_title
        inside_title = true
        current_full_dir = File.dirname(f)
        current_internet_archive_id = current_full_dir.split("/")[-1]
        current_title = Title.create(:path => current_full_dir, :internet_archive_id => current_internet_archive_id)
        # Page.create(:title_id => current_title, :page_id => File.basename(f, '.txt'))
      # elsif File.file?(f) && inside_title
      #   Page.create(:title_id => current_title.id, :page_id => File.basename(f, '.txt'))
      elsif !File.file?(f) && inside_title
        inside_title = false
      end
    end
  end

  def send_text
    res = RestClient.post(BHLIndexer::Config.gnrd_api_url, :format => 'json', :text => concatenated_text, :engine => 0, :unique => false)
    res = JSON.parse(res, :symbolize_names => true)
    @gnrd_url = res[:token_url]
  end

  def get_names
    return unless @gnrd_url
    @names = JSON.parse(RestClient.get(@gnrd_url), :symbolize_names => true)[:names]
    @names = @names.sort_by { |name| name[:offsetStart] } unless @names.blank?
  end

  def names_to_pages
    return if @names.blank?
    prev_offset = 0
    current_name = @names.shift
    pages_offsets.each_with_index do |offset, i|
      if current_name && current_name[:offsetStart] <= offset
        while current_name[:offsetStart] <= offset
          name_offset_start = current_name[:offsetStart] - prev_offset
          coeff = prev_offset
          ends_next_page = false
          if current_name[:offsetEnd] > offset
            ends_next_page = true
            coeff = offset
          end
          name_offset_end = current_name[:offsetEnd] - coeff
          if !current_name[:scientificName].empty?
            name_string = NameString.find_or_create_by_name(current_name[:scientificName])
            PageNameString.create(:page_id => pages_ids[i], :name_string_id => name_string.id, :name_offset_start => name_offset_start, :name_offset_end => name_offset_end, :ends_next_page => ends_next_page)
          end
          current_name = @names.shift
          break unless current_name
        end
      end
      prev_offset = offset
    end
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

  def create_pages
    if Page.where(:title_id => id).limit(1).empty?
      all_pages = @concatenator.pages_ids.map { |p| "(#{id}, #{Title.connection.quote(p)})" }.join(",")
      Title.connection.execute("insert into pages (title_id, id) values #{all_pages}")
      reload
    end
  end

  private

  def concatenate_pages
    @gnrd_url = nil
    @concatenator = BHLIndexer::Concatenator.new(File.join(BHLIndexer::Config.root_file_path, path))
    @concatenator.concatenate
  end
end
