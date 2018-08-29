#!/bin/ruby

require 'sequel'
require 'sqlite3'
require 'pry-nav'
require 'pry'


def init_db(db_name=nil)
  if db_name
    @db_name = db_name
  else
    @db_name = "default.sqlite3"
  end
  @database = Sequel.sqlite(@db_name)
  # create tables if db is empty
#  binding.pry
  if @database.tables.include?(:songs)
    # TODO: check that this songs table has the right schema
  else
    @database.create_table :songs do
      primary_key :song_id
      String      :name, index: true
      String      :artist, index: true
      String      :album
      String      :composer
      String      :genre, index: true
      Integer     :time
      Integer     :year, index: true
      Integer     :bpm
      Integer     :size
      Datetime    :created_at
      Datetime    :updated_at
      unique [:name, :artist]
    end
  end
  if @database.tables.include?(:playlists)
    # TODO: check that this table has the right schema
  else
    @database.create_table :playlists do
      primary_key :playlist_id
      String      :playlist_name, index: {unique: true}, size: 50
    end
  end
  if @database.tables.include?(:playlist_mapping)
    # TODO: check that this table has the right schema
  else
    @database.create_table :playlist_mapping do
      primary_key :id
      foreign_key :song_id, :songs, index: true
      foreign_key :playlist_id, :playlists, index: true
      unique [:song_id, :playlist_id]
    end
  end
end

