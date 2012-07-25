class Title < ActiveRecord::Base
  has_many :pages
  has_one :language, :foreign_key => "internet_archive_id"
  attr_accessor :names
  after_initialize :concatenate_pages

  STATUS = { init: 0, enqueued: 1, sent: 2, completed: 3, failed: 4 } 
  
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
    engine = (self.language.name == 'English') ? 0 : 1
    res = RestClient.post(BHLIndexer::Config.gnrd_api_url, :format => 'json', :text => concatenated_text, :engine => engine, :unique => false)
    res = JSON.parse(res, :symbolize_names => true)
    self.gnrd_url = res[:token_url]
    self.status = Title::STATUS[:sent]
    self.save!
  end

  def get_names
    return unless gnrd_url
    res = JSON.parse(RestClient.get(gnrd_url), :symbolize_names => true)
    @names = res[:names]
    # @names = @names.sort_by { |name| name[:offsetStart] } unless @names.blank?
  end

  def names_to_pages
    create_pages
    return if @names.blank?
    prev_offset = 0
    current_name = @names.shift
    Title.transaction do
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
              name = NameString.normalize(current_name[:scientificName])
              if name
                name_string = NameString.find_or_create_by_name(name)
                PageNameString.create(:page_id => pages_ids[i], :name_string_id => name_string.id, :name_offset_start => name_offset_start, :name_offset_end => name_offset_end, :ends_next_page => ends_next_page)
              end
            end
            current_name = @names.shift
            break unless current_name
          end
        end
        prev_offset = offset
      end
    end
    self.status = Title::STATUS[:completed]
    self.save!
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
    gnrd_url = nil
    @concatenator = BHLIndexer::Concatenator.new(File.join(BHLIndexer::Config.root_file_path, path))
    @concatenator.concatenate
  end

end
