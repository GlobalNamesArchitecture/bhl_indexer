require 'thread'

mutex = Mutex.new

module BHLIndexer
  class ResolverClient
    attr_accessor :batch_size

    RESOLVED_NAMES_HASH = {}
    THREADS_NUM = 3

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
      ids_names = get_ids_and_names(status_number)
      return 0 if ids_names == nil || ids_names.empty?
      ids, names = ids_names.transpose
      puts ids
      ids = ids.join(',')
      NameString.connection.execute("update name_strings set status = %s where id in (%s)" % [NameString::STATUS[:enqueued], ids])
      names_batch = ids_names.map { |i| i.join("|") }.join("\n")
      resource = RestClient::Resource.new(@url, timeout: 9_000_000, open_timeout: 9_000_000, connection: "Keep-Alive")
      r = resource.post(:data => names_batch, :with_context => false, :resolve_once => false)
      r = JSON.parse(r, :symbolize_names => true) rescue nil
      if r && r[:data]
        rr = ResolverResult.new(r)
        rr.process
      end
      ids_names.size
    end
    
    def process_failed_batches(batch_size)
      @batch_size = batch_size
      process_batch(NameString::STATUS[:init])
    end

    private

    def get_ids_and_names(status_number)
      NameString.connection.select_rows("select id, name from name_strings where status is null or status = %s limit %s" % [status_number, @batch_size])
    end

  end

  class ResolverResult
    
    CURATED_SOURCES = [1,2,3,4,5,6,7,8,9,105,132,151,155,158,163,165,167]
    NAME_BANK_ID = 169
    
    def initialize(resolver_result)
      @result = resolver_result
      @found_ids = []
      @not_found_ids = []
      @records = []
    end

    def process
      @result[:data].each do |d|
        name_string_id = d[:supplied_id]
        @found_ids << name_string_id
        d[:results] = d[:results].select {|i| i[:score] > 0.5} if d[:results]
        if d[:results] && !d[:results].empty?
          process_non_empty_results(d[:results], name_string_id)
        else
          @not_found_ids << name_string_id 
        end
      end
      submit_data
    end

    private
    
    def add_resolved_names_hash(canonical_form)
      name_quoted = ResolvedCanonicalForm.connection.quote(canonical_form)
      ResolvedCanonicalForm.connection.execute("insert into resolved_canonical_forms (name, created_at, updated_at) values (%s, now(), now())" % name_quoted)
      canonical_form_id = ResolvedCanonicalForm.connection.select_values("select last_insert_id()")[0]
      ResolverClient::RESOLVED_NAMES_HASH[canonical_form] = canonical_form_id
      canonical_form_id
    end

    def process_non_empty_results(results, name_string_id)
      results_size = results.size
      results = partition_curated_namebank_other(results)
      
      in_curated_source = !results[:curated].empty?
      record = nil
      if in_curated_source 
        record = results[:curated][0]
      else 
        record = results[:other][0]
      end
      
      match_type = record[:match_type]
      record = results[:namebank][0] unless results[:namebank].empty?
      canonical_form_id = get_canonical_form_id(record)
      local_id = record[:local_id] ? record[:local_id].gsub("urn:lsid:ubio.org:namebank:", '') : nil
      @records << [name_string_id.to_i, record[:data_source_id].to_i, local_id, record[:gni_id], canonical_form_id, record[:name_string], record[:score].to_f * 1000, match_type, in_curated_source, results_size, Time.now, Time.now].map { |i| Title.connection.quote(i) }.join(',')
    end

    def get_canonical_form_id(record)
      canonical_form = record[:canonical_form]
      canonical_form_id = ResolverClient::RESOLVED_NAMES_HASH[canonical_form]
      canonical_form_id = add_resolved_names_hash(canonical_form) unless canonical_form_id
      canonical_form_id
    end

    def partition_curated_namebank_other(results)
      results = results.inject({:curated => [], :namebank => [], :other => []}) do |res, r|
        if CURATED_SOURCES.include? r[:data_source_id]
          res[:curated] << r
        else
          res[:other] << r
          res[:namebank] << r if r[:data_source_id] == NAME_BANK_ID
        end
        res
      end
      results.keys.each { |k| results[k].sort_by! { |r| r[:match_type] } }
      results
    end

    def submit_data
      Title.transaction do
        Title.connection.execute("INSERT IGNORE resolved_name_strings (name_string_id, data_source_id, local_id, gni_id, canonical_form_id, name, score, match_type, in_curated_sources, finds_num, created_at, updated_at) values (#{@records.join('),(')})") unless @records.empty?
        Title.connection.execute("update name_strings set status = #{NameString::STATUS[:found]} where id in (#{@found_ids.join(',')})") unless @found_ids.empty?
        Title.connection.execute("update name_strings set status = #{NameString::STATUS[:not_found]} where id in (#{@not_found_ids.join(',')})") unless @not_found_ids.empty?
      end
    end
  end
end
