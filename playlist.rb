#!/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
require File.dirname(__FILE__)+ '/database.rb'

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
    formatted[:updated_at] = Time.now()
    if dataset.where(:artist=>formatted[:artist],
                     :name=>formatted[:name]).empty?
      # TODO: add logic for updated_at?
      dataset.insert(formatted)
    end
  end
end

# TODO: better error handling for the web app
##
# Create a playlist from the songs currently in the database
# Playlist types are decade (90's) or genre (Rock)
def create_playlist(type, name)
  name.downcase!
  # check if playlist is already created, if so delete and create again
  if !@database.from(:playlists).where(:playlist_name => name).empty?
    playlist = @database.from(:playlists).where(:playlist_name => name)
    id = playlist.select(:playlist_id).single_value
    # delete playlist from playlists and playlist_mapping
    @database.from(:playlist_mapping).where(:playlist_id => id).delete
    @database.from(:playlists).where(:playlist_name => name).delete
  end
  case type
  when "genre"
    songs = @database.from(:songs).grep(Sequel.function(:lower, :genre),
                                        "%#{name}%")
  when "decade"
    if !name.match(/^\d0's$/)
      puts "Invalid Input: please format the decade using the plural of its " +
           "numerical decade, for ex. 80's, 90's, or 00's"
      exit
    end
    year = name.chomp("'s").to_i
    year = year <= 10 ? year + 2000 : year + 1900
    songs = @database.from(:songs).where(:year => Array(year..(year+9)))
  else
    puts "Invalid type. The only supported playlist types are decade and genre."
    exit
  end
  # create playlists entry
  playlist_id = @database.from(:playlists).insert(:playlist_name => name)
  # create playlist_mapping for each of the songs
  songs.each do |song|
    @database.from(:playlist_mapping).insert(:song_id => song[:song_id],
                                             :playlist_id => playlist_id)
  end
end

def get_playlist(name)
  name.downcase!
  playlist = @database.from(:playlists).where(playlist_name: name)
  id = playlist.select(:playlist_id).single_value
  dataset = @database.from(:playlist_mapping).where(playlist_id: id)
  songs = dataset.join(:songs, :song_id=>:song_id).order(:bpm).to_a
  return songs
end
