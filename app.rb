#!/bin/ruby

require 'sinatra/base'
require 'thin'
require File.dirname(__FILE__)+'/playlist.rb'

class AppServer < Sinatra::Base

  def self.run!
    app = PlaylistApp.new()
    set :app, app
    set :database, app.database
    set :db_name, app.db_name
    super
  end
  
  get '/' do
    @title = "Welcome to the Playlist Generator!"
    @songs = settings.database.from(:songs).limit(10).to_a
    @count = settings.database.from(:songs).count
    @table_desc = "Displaying the first 10 songs (#{@count} total)."
    erb :song_table
  end

  # TODO
  post '/init_db/:name' do
    settings.app.init_db(params['db_name'])
    set :database, settings.app.database
    set :db_name, settings.app.db_name
  end
  
  get '/load_songs' do
    erb :load_songs
  end

  post '/load_songs' do
    settings.app.load_from_file(params["file"]["tempfile"])
    @title = "Load success!"
    # TODO: display only the songs the user just uploaded
    @table_desc = "Displaying the last 10 songs to be added to the database"
    @songs = settings.database.from(:songs).order(:updated_at).limit(10).to_a
    erb :song_table
  end

  get '/all_songs' do
    @count = settings.database.from(:songs).count
    @table_desc = "Showing all songs (#{@count} total)"
    @songs = settings.database.from(:songs).order(:updated_at).to_a
    erb :song_table
    # TODO: could add option to sort by column on click
  end

  get '/playlists' do
    @playlists = settings.database.from(:playlists).select(:playlist_name)
                   .order(:playlist_name).to_a
    @table_desc = "Displaying all playlists (#{@playlists.size} total)"
    erb :playlist_table
  end

  get '/playlist/:name' do
    # TODO: "bug", have to manually recreate playlist to see newly added songs
    @songs = settings.app.get_playlist(params['name'])
    @table_desc = "Displaying the #{params['name']} playlist " +
                  "(#{@songs.size} songs)"
    erb :song_table
  end
  
  get '/create_playlist' do
    @title = "Create new playlist"
    erb :create_playlist
  end
  
  post '/create_playlist' do
    settings.app.create_playlist(params['type'], params['name'])
    @songs = settings.app.get_playlist(params['name'])
    @table_desc = "Displaying the #{params['name']} playlist"
    erb :song_table
  end

end # end Class ApplicationController

AppServer.run!
