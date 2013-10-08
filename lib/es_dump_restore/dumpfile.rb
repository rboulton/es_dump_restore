require 'zip'
require 'multi_json'

module EsDumpRestore
  class Dumpfile < Zip::File
    def self.write(filename, &block)
      df = Dumpfile.new(filename, Zip::File::CREATE)
      begin
        yield df
      ensure
        df.close
      end
    end

    def self.read(filename, &block)
      df = Dumpfile.new(filename)
      begin
        yield df
      ensure
        df.close
      end
    end

    def get_objects_input_stream(&block)
      get_input_stream("objects", &block)
    end

    def get_objects_output_stream(&block)
      get_output_stream("objects", nil, &block)
    end

    def num_objects
      read_json_file("num_objects.json")["num_objects"]
    end

    def num_objects=(n)
      write_json_file("num_objects.json", {num_objects: n})
    end

    def scan_objects(batch_size, &block)
      get_objects_input_stream do |input|
        loop do
          commands = ""
          items = 0

          batch_size.times do
            metadata = input.gets("\n")
            break if metadata.nil?
            commands << metadata

            source = input.gets("\n")
            commands << source

            items += 1
          end
          break if commands.empty?

          yield commands, items
        end
      end
    end

    def index=(index)
      write_json_file("index.json", index)
    end

    def index
      read_json_file("index.json")
    end

    private
    def read_json_file(filename)
      get_input_stream(filename) { |i| MultiJson.load(i.read) }
    end

    def write_json_file(filename, object)
      get_output_stream(filename) { |o| o.write MultiJson.dump(object) }
    end
  end
end