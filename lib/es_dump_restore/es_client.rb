require 'uri'
require 'httpclient'
require 'multi_json'

module EsDumpRestore
  class EsClient
    attr_accessor :base_uri
    attr_accessor :index_name

    def initialize(base_uri, index_name, type)
      @httpclient = HTTPClient.new
      @index_name = index_name

      @es_uri = base_uri
      @path_prefix = type.nil? ? index_name : index_name + "/" + type
    end

    def mappings
      data = request(:get, "#{@path_prefix}/_mapping")
      if data.values.size != 1 || data.values.first["mappings"].nil?
        raise "Unexpected response: #{data}"
      end
      data.values.first["mappings"]
    end

    def settings
      data = request(:get, "#{@path_prefix}/_settings")
      if data.values.size != 1 || data.values.first["settings"].nil?
        raise "Unexpected response: #{data}"
      end
      data.values.first["settings"]
    end

    def start_scan(&block)
      scroll = request(:get, "#{@path_prefix}/_search",
        query: { search_type: 'scan', scroll: '10m', size: 500 },
        body: MultiJson.dump({ query: { match_all: {} } }) )
      total = scroll["hits"]["total"]
      scroll_id = scroll["_scroll_id"]

      yield scroll_id, total
    end

    def each_scroll_hit(scroll_id, &block)
      done = 0
      loop do
        batch = request(:get, '_search/scroll', {query: {
          scroll: '10m', scroll_id: scroll_id
        }}, [404])

        batch_hits = batch["hits"]
        break if batch_hits.nil?
        hits = batch_hits["hits"]
        break if hits.empty?

        hits.each do |hit|
          yield hit
        end

        total = batch_hits["total"]
        done += hits.size
        break if done >= total
      end
    end

    def create_index(metadata)
      request(:post, "#{@path_prefix}", :body => MultiJson.dump(metadata))
    end

    def bulk_index(data)
      request(:post, "#{@path_prefix}/_bulk", :body => data)
    end

    private

    def request(method, path, options={}, extra_allowed_exitcodes=[])
      request_uri = @es_uri + "/" + path
      begin
        response = @httpclient.request(method, request_uri, options)
        unless response.ok? or extra_allowed_exitcodes.include? response.status
          raise "Request failed with status #{response.status}: #{response.reason}"
        end
        MultiJson.load(response.content)
      rescue Exception => e
        puts "Exception caught issuing HTTP request to #{request_uri}"
        puts "options: #{options}"
        raise e
      end
    end
  end
end
