require "rubygems"

require "benchmark"
require "mongo"
require "nokogiri"
require "pp"

include Mongo

RAM_DISK_SIZE = 1024 * 1024 * 256
RAM_DISK_SECTORS = RAM_DISK_SIZE / 512

# TODO: Make this work with non OSX systems
# TODO: What's the conventional method of avoiding accidental naming conflicts
system("./system/create_ramdisk.sh &> traktordb.log")

# TODO: Dynamically choose a port number to not conflict with existing mongod processes
system("mongod --config ./system/mongod.conf &> traktordb.log &")

# TODO: Block until mongod and ramdisk are complete
mongo_client = MongoClient.new('localhost', 27017)
mongo_db = mongo_client['traktor']
mongo_collection = mongo_db['music']

doc = Nokogiri::XML(File.open("collection.nml"))

doc_head = doc.xpath("//HEAD")
doc_musicfolders = doc.xpath("//MUSICFOLDERS")
doc_collection = doc.xpath("//COLLECTION")
doc_playlists = doc.xpath("//PLAYLISTS")

def node_to_hash(node)
  hash = {}
  node.attributes.each do | k, v |
    hash[k] = v.value
  end
  node.children.each do | child |
    hash[child.name] = node_to_hash(child)
  end
  return hash
end

time_nokogiri = 0
time_mongo = 0

all_entries = []
doc_collection.children.each do | entry |
  entry_hash = nil
  time_nokogiri += Benchmark.realtime do
    entry_hash = node_to_hash(entry)
    all_entries.push(entry_hash)
  end
end

time_mongo = Benchmark.realtime do
  mongo_collection.insert(all_entries)
end

puts "Nokogiri Time: %.3fms" % (time_nokogiri * 1000)
puts "Mongo Time: %.3fms" % (time_mongo * 1000)
pp mongo_collection.stats

# TODO: This should happen even with exceptional behaviour
system("./system/stop_mongod.sh")
system("./system/delete_ramdisk.sh")
