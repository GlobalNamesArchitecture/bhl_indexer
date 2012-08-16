class Title < ActiveRecord::Base
  has_many :pages
  attr_accessor :names
  after_initialize :concatenate_pages
  NAMES_HASH = {}

  STATUS = { init: 0, enqueued: 1, sent: 2, completed: 3, failed: 4 }
  
  def self.populate
    root_path = BHLIndexer::Config.root_file_path
    Dir.chdir(root_path)
    inside_title = false
    current_full_dir = nil
    current_internet_archive_id = nil
    current_title = nil
    Find.find(".").each do |f|
      next if f.include? "DS_Store"
      if File.file?(f) && !inside_title
        inside_title = true
        current_full_dir = File.dirname(f)
        current_internet_archive_id = current_full_dir.split("/")[-1]
        language = Language.find_by_internet_archive_id(current_internet_archive_id).name rescue nil
        current_title = Title.create(:path => current_full_dir, :internet_archive_id => current_internet_archive_id, :language => language)
        # Page.create(:title_id => current_title, :page_id => File.basename(f, '.txt'))
      # elsif File.file?(f) && inside_title
      #   Page.create(:title_id => current_title.id, :page_id => File.basename(f, '.txt'))
      elsif !File.file?(f) && inside_title
        inside_title = false
      end
    end
  end

  def send_text
    params = { :text => concatenated_text, :engine => 0, :detect_language => "false", :unique => "false" }
    url = BHLIndexer::Config.gnrd_api_url
    if url.include?("gnrd") || url.include?("128.128")
      addressable = Addressable::URI.new
      addressable.query_values = params
      gz_payload = ActiveSupport::Gzip.compress(addressable.query)

      uri = URI(url)
      req = Net::HTTP::Post.new(uri.path)
      req["Content-Encoding"] = "GZIP"
      req["Content-Length"] = gz_payload.size
      req["X-Uncompressed-Length"] = addressable.query.size
      req.body = gz_payload

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      
      if[302, 303].include? res.response.code.to_i
        save_location(res.header.to_hash["location"][0])
      end
    else
      res = RestClient.post(BHLIndexer::Config.gnrd_api_url, params) do |response, request, result, &block|
        if [302, 303].include? response.code
          save_location(response.headers[:location])
        end
      end
    end
  end
  
  def save_location(url)
    self.gnrd_url = url
    self.status = Title::STATUS[:sent]
    self.save!
  end

  def get_names
    return unless gnrd_url
    res = JSON.parse(RestClient.get(gnrd_url), :symbolize_names => true)
    if res[:status] == 500
      self.status = Title::STATUS[:failed]
      self.save!
    end
    @names = res[:names]
    @is_english = res[:english]
  end

  def names_to_pages
    create_pages
    return if @names.blank?
    prev_offset = 0
    current_name = @names.shift
    data = []
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
                name_string_id = Title::NAMES_HASH[name]
                unless name_string_id
                  name_quoted = NameString.connection.quote(name)
                  NameString.connection.execute("insert into name_strings (name, created_at, updated_at) values (%s, now(), now())" % name_quoted)
                  name_string_id = NameString.connection.select_values("select last_insert_id()")[0]
                  Title::NAMES_HASH[name] = name_string_id
                end
                data << ["'" + pages_ids[i] + "'", name_string_id, name_offset_start, name_offset_end, ends_next_page, 'now()', 'now()']
                if data.size % 10000 == 0
                  add_pages_data(data)
                  data = []
                end
              end
            end
            current_name = @names.shift
            break unless current_name
          end
        end
        prev_offset = offset
      end
      add_pages_data(data)
    end
    self.status = Title::STATUS[:completed]
    self.save!
  end

  def add_pages_data(data)
    data = data.map{|d| d.join(',')}.join('),(')
    PageNameString.connection.execute("insert into page_name_strings (page_id, name_string_id, name_offset_start, name_offset_end, ends_next_page, updated_at, created_at) values (%s)" % data)
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
    self.english = @is_english
    self.save!
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
