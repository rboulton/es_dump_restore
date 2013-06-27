# es_dump_restore

A utility for safely dumping the contents of an ElasticSearch index to a compressed file and restoring it
later on.  This can be used for backups or for cloning an ElasticSearch index without needing to take down
the server.

The file format is a ZIP file containing the index metadata, the number of objects in the index, and a
series of commands to be sent to the ElasticSearch bulk API.

## Installation

    gem install es_dump_restore

## Usage

To dump an ElasticSearch index to a file:

    es_dump_restore dump ELASTIC_SEARCH_SERVER_URL INDEX_NAME DESTINATION_FILE_ZIP

To dump an ElasticSearch index by type to a file:

    es_dump_restore dump ELASTIC_SEARCH_SERVER_URL INDEX_NAME TYPE DESTINATION_FILE_ZIP

To restore an index to an ElasticSearch server:

    es_dump_restore restore ELASTIC_SEARCH_SERVER_URL DESTINATON_INDEX FILENAME_ZIP

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
