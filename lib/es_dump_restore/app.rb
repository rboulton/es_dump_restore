require "es_dump_restore/es_client"
require "es_dump_restore/dumpfile"
require "thor"
require "progress_bar"
require "multi_json"

module EsDumpRestore
  class App < Thor

    desc "dump URL INDEX_NAME FILENAME", "Creates a dumpfile based on the given ElasticSearch index"
    def dump(url, index_name, filename)
      client = EsClient.new(url, index_name, nil)

      Dumpfile.write(filename) do |dumpfile|
        dumpfile.index = {
          settings: client.settings,
          mappings: client.mappings
        }

        client.start_scan do |scroll_id, total|
          dumpfile.num_objects = total
          bar = ProgressBar.new(total)

          dumpfile.get_objects_output_stream do |out|
            client.each_scroll_hit(scroll_id) do |hit|
              metadata = { index: { _type: hit["_type"], _id: hit["_id"] } }
              out.write("#{MultiJson.dump(metadata)}\n#{MultiJson.dump(hit["_source"])}\n")
              bar.increment!
            end
          end
        end
      end
    end

    desc "dump_type URL INDEX_NAME TYPE FILENAME", "Creates a dumpfile based on the given ElasticSearch index"
    def dump_type(url, index_name, type, filename)
      client = EsClient.new(url, index_name, type)

      Dumpfile.write(filename) do |dumpfile|
        dumpfile.index = {
          settings: client.settings,
          mappings: client.mappings
        }

        client.start_scan do |scroll_id, total|
          dumpfile.num_objects = total
          bar = ProgressBar.new(total)

          dumpfile.get_objects_output_stream do |out|
            client.each_scroll_hit(scroll_id) do |hit|
              metadata = { index: { _type: hit["_type"], _id: hit["_id"] } }
              out.write("#{MultiJson.dump(metadata)}\n#{MultiJson.dump(hit["_source"])}\n")
              bar.increment!
            end
          end
        end
      end
    end

    desc "restore URL INDEX_NAME FILENAME", "Restores a dumpfile into the given ElasticSearch index"
    def restore(url, index_name, filename)
      client = EsClient.new(url, index_name, nil)

      Dumpfile.read(filename) do |dumpfile|
        client.create_index(dumpfile.index)

        bar = ProgressBar.new(dumpfile.num_objects)
        dumpfile.scan_objects(1000) do |batch, size|
          client.bulk_index batch
          bar.increment!(size)
        end
      end
    end

  end
end