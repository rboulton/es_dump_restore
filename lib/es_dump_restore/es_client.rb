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

      @base_uri = type.nil? ? URI.parse(base_uri + "/" + index_name + "/") : URI.parse(base_uri + "/" + index_name + "/" + type + "/")
    end

    def mappings
      request(:get, '_mapping')[index_name]
    end

    def settings
      request(:get, '_settings')[index_name]
    end

    def start_scan(&block)
      scroll = request(:get, '_search',
        query: { search_type: 'scan', scroll: '10m', size: 500 },
        body: MultiJson.dump({ query: { match_all: {} } }) )
      total = scroll["hits"]["total"]
      scroll_id = scroll["_scroll_id"]

      yield scroll_id, total
    end

    def each_scroll_hit(scroll_id, &block)
      loop do
        batch = request(:get, '/_search/scroll', query: {
          scroll: '10m', scroll_id: scroll_id
        })

        batch_hits = batch["hits"]
        break if batch_hits.nil?
        hits = batch_hits["hits"]
        break if hits.empty?

        hits.each do |hit|
          yield hit
        end
      end
    end

    def create_index(metadata)
      request(:post, "", :body => MultiJson.dump(metadata))
    end

    def bulk_index(data)
      request(:post, "_bulk", :body => data)
    end

    private

    def request(method, path, options={})
      request_uri = @base_uri + path
      response = @httpclient.request(method, request_uri, options)
      MultiJson.load(response.content)
    end
  end
end