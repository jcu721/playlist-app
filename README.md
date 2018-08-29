# playlist-app
Simple Ruby application that reads json files containing songs into a database
and creates playlists from the song catalog.

## Prerequisites
The following steps are tested on Fedora 28.
This app uses a Sinatra web server and a SQLite database to serve web pages.

1. Install Ruby
`# yum install ruby`
* Install sqlite `# yum install sqlite-devel`
* Install bundle `# yum install rubygem-bundler`
* Run `# bundle install` to install the necessary ruby gems from the Gemfile

## Running the App
1. Start the server
   `ruby app.rb`
* Navigate to `http://localhost:4567` to interact with the app

## Running tests
Tests are provided that use rspec.

`# yum install rubygem-rspec-core`
TODO: info for running tests

## Built With
* [Ruby](https://www.ruby-lang.org/en/) Backend
* [Sinatra](http://sinatrarb.com/) webserver
* [SQLite](https://www.sqlite.org) database
