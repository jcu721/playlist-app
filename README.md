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

   If any of the gems give you trouble, try installing through fedora (prefixed
   with rubygem-#{name}), for example `sudo yum install rubygem-thin`

3. Start the server from within the project.
   `ruby app.rb`
4. Navigate to `http://localhost:4567` to interact with the app, add songs, and
   create playlists.
5. To finish, CTRL-C out of the server process.

## Running tests
Tests are provided that use rspec.

`# yum install rubygem-rspec-core`
TODO: info for running tests

## Built With
* [Ruby](https://www.ruby-lang.org/en/) Backend
* [Sinatra](http://sinatrarb.com/) webserver
* [SQLite](https://www.sqlite.org) database

## Known Issues
* Error handling is not very robust. Invalid song entries could cause inserts
  to break, errors are not bubbled up from playlist.rb to the user (exit on
  invalid create_playlist params causes internal server error instead).
* Web app would probably not handle large volumes of data well, would need to
  implement some sort of pagination/incremental loading of songs.
* If you create a playlist before adding any songs to the db, that playlist
  would get persisted with no songs and would not be updated with any new songs
  unless you specifically recreated the playlist of that name.
* There is no current way for the updated_at variable to be updated. Currently
  the app ignores new add requests for songs already in the db (as apposed to
  updating the values and the updated_at timestamp)

## Future Enhancements
* API support for deleting playlists and updating playlists after adding new
  songs
* During /load_songs, if any songs don't meet validation criteria, return these
  to the user for review.
* After /load_songs, display back to the user the number of new songs added and
  show only the songs that were just uploaded.
* Add the option to sort by column asc/desc on the /all_songs page.
* On the create_playlist page, show user list of options for Genres, pulled
  from the current set of songs
* Support for changing the database from the default one, or resetting the db
  entirely from the web UI
* The user is only shown a subset of the song's data (size, time, and composer
  are left out) to conserve space. Adding a way to expand a song's row to show
  all of this information.

