#!/bin/ruby

require 'sinatra'
require 'thin'
require File.dirname(__FILE__)+'/playlist.rb'

#class AppController < Sinatra::Base

  before do
    init_db
  end
  
  get '/' do
    @title = "Welcome to the Playlist Generator!"
    @songs = @database.from(:songs).limit(10).to_a
    @table_desc = "Displaying the first 10 songs from the DB."
    erb :song_table
  end
  
  post '/init_db/name' do
    init_db(params['db_name'])
  end
  
  get '/load_songs' do
    erb :load_songs
  end

  post '/load_songs' do
    load_from_file(params["file"]["tempfile"])
    @title = "Load success"
    @table_desc = "10 latest songs to be added to the database"
    @songs = @database.from(:songs).order(:updated_at).limit(10).to_a
    erb :song_table
  end

  get '/playlists' do
    @playlists = @database.from(:playlists).select(:playlist_name).order(:playlist_name).to_a
    @table_desc = "Displaying all playlists"
    erb :playlist_table
  end

  get '/playlist/:name' do
    @songs = get_playlist(params['name'])
    @table_desc = "Displaying the #{params['name']} playlist"
    erb :song_table
  end
  
  get '/create_playlist' do
    @title = "Create new playlist"
    erb :create_playlist
  end
  
  post '/create_playlist' do
    create_playlist(params['type'], params['name'])
    @songs = get_playlist(params['name'])
    @table_desc = "Displaying the #{params['name']} playlist"
    erb :song_table
  end

  
#end # end Class ApplicationController


