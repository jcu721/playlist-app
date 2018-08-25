#!/bin/ruby

require 'sequel'
require 'sqlite3'
require 'pry-nav'
require 'pry'


def init_db
  db_name = "playlist_app.sqlite3"
  @database = Sequel.sqlite(db_name)
  # create tables if db is empty
#  binding.pry
  if @database.tables.include?(:songs)
    # TODO: check that this songs table has the right schema
  else
    @database.create_table :songs do
      primary_key :id
      String      :name
      String      :artist
      String      :album
      String      :composer
      String      :genre
      Integer     :time
      Integer     :year
      Integer     :bpm
      Integer     :size
      Datetime    :created_at
      Datetime    :updated_at
    end
  end
  @database.schema(:songs)
end

