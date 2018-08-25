#!/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
load 'database.rb'

=begin
Validation / Data cleanup rules:
- Minimum song duration is 60 seconds
- Minimum BPM is 100
- Song must contain all required database song field values
- Songs by the Bee Gees or Linkin Park may not be added to the database
- Subgenres should be coerced into parent genres. For example, any
variations of "rock" and "alternative" should be associated with the "Rock"
and "Alternative" genres.

Json: 
[  {
    "Name": "All the Right Moves",
    "Artist": "OneRepublic",
    "Composer": "Ryan Tedder",
    "Album": "Waking Up (Deluxe Version)",
    "Genre": "Rock",
    "BPM": 146,
    "Size": 8634363,
    "Time": 237,
    "Year": 2009
  }]
=end

##
# Validate a song entry
def validate(song)
  # TODO other basic checks such as bpm, size, time, and year are ints
  # song must contain all required database song field values
  return false if song.keys.sort != ["Album", "Artist", "BPM", "Composer",
                                     "Genre", "Name", "Size", "Time", "Year"]
  # song duration must be at least 60 seconds
  return false if song["Time"] < 60
  # BPM must be at least 100
  return false if song["BPM"] < 100
  # Songs by the Bee Gees or Linkin Park may not be added to the database
  return false if ["The Bee Gees", "Linkin Park"].include?(song["Artist"])
  return true
end


# TODO: set name and artist = to unique key, can insert muliple of the same songs
# TODO: mess with the  formatted[:updated_at] = Time.now()

##
# Load a json file and insert as songs in the database
def load_from_file(filename)
  file = open(filename)
  json = file.read
  songs_to_add = JSON.parse(json)
  songs_to_add.keep_if{|song| validate(song)}
  dataset = @database.from(:songs)
  songs_to_add.each do |song|
    dataset = @database.from(:songs)
    formatted = {}
    song.each_pair.collect{|key, val| formatted[key.downcase.to_sym] = val}
    formatted[:created_at] = Time.now()
    dataset.insert(formatted)
  end
end

def create_genre_playlist(genre)

end

def create_decade_playlist(decade)

end

init_db
load_from_file("mr_playlist.json")

