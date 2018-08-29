# playlist-app
Simple Ruby application that reads json files containing songs into a database
and creates playlists from the song catalog.

## Prerequisites
The following steps are tested on Fedora 28.
This app uses a Sinatra web server and a SQLite database to serve web pages.

1. Install Ruby   `# yum install ruby ruby-devel`
2. Install sqlite `# yum install sqlite-devel rubygem-sqlite3`
3. Install bundle `# yum install rubygem-bundler`

## Running the App
1. Clone/download the project from git and cd into the playlist-app directory.
2. Run `# bundle install` to install the necessary ruby gems from the Gemfile.
---
   If any of the gems give you trouble, try installing through fedora (prefixed
   with rubygem-#{name}), for example `sudo yum install rubygem-thin`

3. Start the server from within the project. 
   `ruby app.rb`
4. Navigate to `http://localhost:4567` to interact with the app, add songs, and
   create playlists. 

## Running tests
Tests are provided that use rspec.

`# yum install rubygem-rspec-core`
TODO: info for running tests

## Built With
* [Ruby](https://www.ruby-lang.org/en/) Backend
* [Sinatra](http://sinatrarb.com/) webserver
* [SQLite](https://www.sqlite.org) database
