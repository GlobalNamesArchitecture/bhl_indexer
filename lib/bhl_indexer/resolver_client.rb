module BHLIndexer
  class ResolverClient
    def initialize
      @url = BHLIndexer::Config.resolver_api_url
      @batch_size = 1000
    end

    def process_batch(status_number = NameString::STATUS[:init])
      ids_names = NameString.connection.select_rows("select id, name from name_strings where status is null or status = %s limit %s" % [status_number, @batch_size])
      return 0 if ids_names == nil || ids_names.empty?
      ids, names = ids_names.transpose
      ids = ids.join(',')
      NameString.connection.execute("update name_strings set status = 1 where id in (%s)" % ids)
      names_batch = ids_names.map { |i| i.join("|") }.join("\n")
      resource = RestClient::Resource.new(@url, timeout: 9_000_000, open_timeout: 9_000_000, connection: "Keep-Alive")
      puts names_batch
      r = resource.post(:data => names_batch, :with_context => false, :resolve_once => false)
      r = JSON.parse(r, :symbolize_names => true) rescue nil
      if r[:data]
        found_ids = []
        not_found_ids = []
        records = []
        r[:data].each do |d|
          name_string_id = d[:supplied_id]
          found_ids << name_string_id
          d[:results] = d[:results].select {|i| i[:score] > 0.5} if d[:results]

          if d[:results] && !d[:results].empty?
            bhl, other = d[:results].partition { |i| [12, 169].include?(i[:data_source_id].to_i) }
            if bhl.empty?
              i = other[0]
              canonical_form_id = nil
              unless i[:canonical_form].empty?
                canonical_form_id = ResolvedCanonicalForm.find_or_create_by_name(i[:canonical_form]).id
              end
              records << [name_string_id.to_i, i[:data_source_id].to_i, i[:local_id], i[:gni_uuid], canonical_form_id, i[:name_string], i[:score].to_f * 1000, i[:match_type]].map { |i| Title.connection.quote(i) }.join(',')
            else
              bhl.each do |i|
                canonical_form_id = nil
                if i[:canonical_form] and i[:canonical_form] != ""
                  canonical_form_id = ResolvedCanonicalForm.find_or_create_by_name(i[:canonical_form]).id
                end
                records << [name_string_id.to_i, i[:data_source_id].to_i, i[:local_id].gsub("urn:lsid:ubio.org:namebank:",''), i[:gni_uuid] , canonical_form_id, i[:name_string], i[:score].to_f * 1000, i[:match_type]].map {|i| Title.connection.quote(i)}.join(',')
              end
            end
            else
              not_found_ids << name_string_id 
          end
        end
        
          Title.connection.execute("INSERT IGNORE resolved_name_strings (name_string_id, data_source_id, local_id, gni_id, canonical_form_id, name, score, match_type) values (#{records.join('),(')})") unless records.empty?
        Title.connection.execute("update name_strings set status = #{NameString::STATUS[:found]} where id in (#{found_ids.join(',')})") unless found_ids.empty?
        Title.connection.execute("update name_strings set status = #{NameString::STATUS[:not_found]} where id in (#{not_found_ids.join(',')})") unless not_found_ids.empty?
      end
      ids_names.size
    end

    def process_failed_batches(batch_size)
      @batch_size = batch_size
      process_batch(NameString::STATUS[:init])
    end

  end
end
