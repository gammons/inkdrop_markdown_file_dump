# Inkdrop markdown file export

This is a simple program that will export all Inkdrop documents to markdown files
in a directory.

## Setup

#### Set up CouchDB locally

This script requires running CouchDB locally, and syncing your Inkdrop instance
with that couchDB.  To do this, run couchDB:

```
docker run -p 5984:5984 -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password couchdb
```

Then create the inkdrop database:

```
curl -X PUT http://admin:password@127.0.0.1:5984/inkdrop
```

#### Update inkdrop settings

Then, go to Inkdrop settings, and tell Inkdrop to use this couchdb instance.
The url will be `http://admin:password@127.0.0.1:5984/inkdrop`

#### Synchronize Inkdrop

Run a sync to populate the current content in inkdrop into the local CouchDB instance.


#### Run the script

1. Run `bundle` to install libraries
2. Run `rake export`.
