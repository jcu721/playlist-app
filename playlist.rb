#!/bin/ruby
require 'rubygems'
require 'json'
require 'pp'

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
  #TODO other basic checks such as bpm, size, time, and year are ints
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

def load_from_file(filename)
  file = open(filename)
  json = file.read
  @songs = JSON.parse(json)
  @songs2 = JSON.parse(json)
  @songs.keep_if{|song| validate(song)}
end

def create_genre_playlist(genre)

end

def create_decade_playlist(decade)

end

load_from_file("mr_playlist.json")
names1 = @songs.collect {|x| x["Name"]}
names2 = @songs2.collect {|x| x["Name"]}
diff = names2 - names1
pp diff

