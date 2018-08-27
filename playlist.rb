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
# Validate a song entry (before adding to db)
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
    formatted = {}
    song.each_pair.collect{|key, val| formatted[key.downcase.to_sym] = val}
    formatted[:created_at] = Time.now()
    if dataset.where(:artist=>formatted[:artist],
                     :name=>formatted[:name]).empty?
      dataset.insert(formatted)
    end
  end
end

#TODO: can probably abstract out most of the genre/decade code into a common func

def create_genre_playlist(genre)
  genre.downcase!
  # check if playlist is already created, if so delete and create again
  if !@database.from(:playlists).where(:playlist_name => genre).empty?
    playlist = @database.from(:playlists).where(:playlist_name => genre)
    id = playlist.select(:playlist_id).single_value
    # delete playlist from playlists and playlist_mapping
    @database.from(:playlist_mapping).where(:playlist_id => id).delete
    @database.from(:playlists).where(:playlist_name => genre).delete
  end
  songs = @database.from(:songs).grep(Sequel.function(:lower, :genre),
                                        "%#{genre}%")
  # create playlists entry
  playlist_id = @database.from(:playlists).insert(:playlist_name => genre)
  # create playlist_mapping for each of the songs
  songs.each do |song|
    @database.from(:playlist_mapping).insert(:song_id => song[:song_id],
                                             :playlist_id => playlist_id)
  end
end

##
# Create a playlist given a decade (90's for ex)
def create_decade_playlist(decade)
  if !decade.match(/^\d0's$/)
    puts "Invalid Input: please format the decade using the plural of its " +
         "numerical decade, for ex. 80's, 90's, or 00's"
    exit
  end
  # check if playlist is already created, if so delete and create again
  if !@database.from(:playlists).where(:playlist_name => decade).empty?
    playlist = @database.from(:playlists).where(:playlist_name => decade)
    id = playlist.select(:playlist_id).single_value
    # delete playlist from playlists and playlist_mapping
    @database.from(:playlist_mapping).where(:playlist_id => id).delete
    @database.from(:playlists).where(:playlist_name => decade).delete
  end
  year = decade.chomp("'s").to_i
  year = year <= 10 ? year + 2000 : year + 1900
  songs = @database.from(:songs).where(:year => Array(year..(year+9)))
  # create playlists entry
  playlist_id = @database.from(:playlists).insert(:playlist_name => decade)
  # create playlist_mapping for each of the songs
  songs.each do |song|
    @database.from(:playlist_mapping).insert(:song_id => song[:song_id],
                                             :playlist_id => playlist_id)
  end
end

def get_playlist(name)
  binding.pry
  name.downcase!
  playlist = @database.from(:playlists).where(playlist_name: name)
  id = playlist.select(:playlist_id).single_value
  # TODO: finish this query
end

init_db
load_from_file("mr_playlist.json")
create_decade_playlist("90's")
create_genre_playlist("Rock")
get_playlist("Rock")
