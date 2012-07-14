module BHLIndexer
  class ResolverClient
    def initialize
      @url = BHLIndexer::Config.resolver_api_url
      @batch_size = 1000
    end

    def process_batch
      ids_names = NameString.connection.select_rows("select id, name from name_strings where status is null or status = %s limit %s" % [NameString::STATUS[:init], @batch_size])
      ids, names = ids_names.transpose
      ids = ids.join(',')
      NameString.connection.execute("update name_strings set status = 1 where id in (%s)" % ids)
      names_batch = ids_names.map { |i| i.join("|") }.join("\n")
      resource = RestClient::Resource.new(@url, timeout: 9_000_000, open_timeout: 9_000_000, connection: "Keep-Alive")
      r = resource.post(:names => names_batch, :data_source_ids => "12|169", :with_context => false, :resolve_once => false)
      r = JSON.parse(r, :symbolize_names => true)
      puts r
    end
  end
end
