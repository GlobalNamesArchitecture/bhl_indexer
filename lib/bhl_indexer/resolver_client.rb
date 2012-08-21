module BHLIndexer
  class ResolverClient
    attr_accessor :batch_size

    CURATED_SOURCES = [1,2,3,4,5,6,7,8,9,105,132,151,155,158,163,165,167]
    RESOLVED_NAMES_HASH = {}

    def initialize
      @url = BHLIndexer::Config.resolver_api_url
      @batch_size = 1000
    end
    
    def rebuild_resolved_names_hash
      if RESOLVED_NAMES_HASH.empty?
        ResolvedCanonicalForm.all.each do |n|
          RESOLVED_NAMES_HASH[n.name] = n.id
        end
      end
    end

    def process_batch(status_number = NameString::STATUS[:init])
      ids_names = NameString.connection.select_rows("select id, name from name_strings where status is null or status = %s limit %s" % [status_number, @batch_size])
      return 0 if ids_names == nil || ids_names.empty?
      ids, names = ids_names.transpose
      ids = ids.join(',')
      NameString.connection.execute("update name_strings set status = %s where id in (%s)" % [NameString::STATUS[:enqueued], ids])
      names_batch = ids_names.map { |i| i.join("|") }.join("\n")
      resource = RestClient::Resource.new(@url, timeout: 9_000_000, open_timeout: 9_000_000, connection: "Keep-Alive")
      puts names_batch
      r = resource.post(:data => names_batch, :with_context => false, :resolve_once => false)
      r = JSON.parse(r, :symbolize_names => true) rescue nil
      if r && r[:data]
        in_curated_source = 0
        match_type = 0
        found_ids = []
        not_found_ids = []
        records = []
        Title.transaction do
          r[:data].each do |d|
            name_string_id = d[:supplied_id]
            found_ids << name_string_id
            d[:results] = d[:results].select {|i| i[:score] > 0.5} if d[:results]
            if d[:results] && !d[:results].empty?
              data_sources, match_types = d[:results].map {|i| [i[:data_source_id], i[:match_type]]}.transpose
              data_sources.uniq!
              match_types = match_types.uniq.sort
              bhl, other = d[:results].partition { |i| [12, 169].include?(i[:data_source_id].to_i) }
              in_curated_source = (data_sources - CURATED_SOURCES).size < data_sources.size ? 1 : 0 
              match_type = match_types[0]
            
              if bhl.empty?
                i = other[0]
                canonical_form = i[:canonical_form]
                canonical_form_id = RESOLVED_NAMES_HASH[canonical_form]
                unless canonical_form_id
                  canonical_form_id = add_resolved_names_hash(canonical_form)
                end
                records << [name_string_id.to_i, i[:data_source_id].to_i, i[:local_id], i[:gni_uuid], canonical_form_id, i[:name_string], i[:score].to_f * 1000, i[:match_type], Time.now, Time.now].map { |i| Title.connection.quote(i) }.join(',')
              else
                bhl.each do |i|
                  canonical_form = i[:canonical_form]
                  canonical_form_id = RESOLVED_NAMES_HASH[canonical_form]
                  unless canonical_form_id
                  canonical_form_id = add_resolved_names_hash(canonical_form)
                  end
                  records << [name_string_id.to_i, i[:data_source_id].to_i, i[:local_id].gsub("urn:lsid:ubio.org:namebank:",''), i[:gni_uuid] , canonical_form_id, i[:name_string], i[:score].to_f * 1000, i[:match_type], Time.now, Time.now].map {|i| Title.connection.quote(i)}.join(',')
                end
              end
            else
              not_found_ids << name_string_id 
            end
          end
          Title.connection.execute("INSERT IGNORE resolved_name_strings (name_string_id, data_source_id, local_id, gni_id, canonical_form_id, name, score, match_type, created_at, updated_at) values (#{records.join('),(')})") unless records.empty?
          Title.connection.execute("update name_strings set status = #{NameString::STATUS[:found]}, in_curated_source = #{in_curated_source}, match_type = #{match_type} where id in (#{found_ids.join(',')})") unless found_ids.empty?
          Title.connection.execute("update name_strings set status = #{NameString::STATUS[:not_found]} where id in (#{not_found_ids.join(',')})") unless not_found_ids.empty?
        end
      end
      ids_names.size
    end
    
    def add_resolved_names_hash(canonical_form)
      name_quoted = ResolvedCanonicalForm.connection.quote(canonical_form)
      ResolvedCanonicalForm.connection.execute("insert into resolved_canonical_forms (name, created_at, updated_at) values (%s, now(), now())" % name_quoted)
      canonical_form_id = ResolvedCanonicalForm.connection.select_values("select last_insert_id()")[0]
      RESOLVED_NAMES_HASH[canonical_form] = canonical_form_id
      canonical_form_id
    end

    def process_failed_batches(batch_size)
      @batch_size = batch_size
      process_batch(NameString::STATUS[:init])
    end

  end
end
