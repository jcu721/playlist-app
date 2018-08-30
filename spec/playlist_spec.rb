require File.dirname(__FILE__)+'/../playlist.rb'
describe PlaylistApp do

  before(:all) do
    test_db = File.dirname(__FILE__) + '/../spec.sqlite'
    if File.exists?(test_db)
      File.delete(test_db)
    end
    @app = PlaylistApp.new("spec.sqlite")
  end

  after(:all) do
    test_db = File.dirname(__FILE__) + '/../spec.sqlite'
    File.delete(test_db)
  end

  describe ".validate" do
    before(:each) do
      @song = JSON.parse('{"Name": "Riptide",
                          "Artist": "Vance Joy",
                          "Composer": "",
                          "Album": "Dream Your Life Away",
                          "Genre": "Indie",
                          "BPM": 148,
                          "Size": 4872171,
                          "Time": 339,
                          "Year": 2013
                         }')
    end

    it "valid songs" do
      expect(@app.validate(@song)).to eql(true)
    end

    it "song length" do
      @song["Time"] = 40
      expect(@app.validate(@song)).to eql(false)
    end

    it "song BPM" do
      @song["BPM"] = 40
      expect(@app.validate(@song)).to eql(false)
    end

    it "forbidden artists" do
      @song["Artist"] = "Linkin Park"
      expect(@app.validate(@song)).to eql(false)
    end

    it "invalid keys" do
      @song["PhoneyKey"] = "Linkin Park"
      expect(@app.validate(@song)).to eql(false)
    end

    it "missing keys" do
      @song.delete("Artist")
      expect(@app.validate(@song)).to eql(false)
    end
  end

  describe '.load_from_file' do
    # database should be empty at start of this
    it 'adds songs to db' do
      @app.load_from_file("spec/json/test.json")
      songs = @app.database.from(:songs).to_a
      expect(songs.size).to eql 2
    end

    it 'discards invalid songs' do
      @app.load_from_file("spec/json/invalid.json")
      songs = @app.database.from(:songs).to_a
      expect(songs.size).to eql 2
    end

    it 'handles duplicate songs' do
      @app.load_from_file("spec/json/duplicate.json")
      songs = @app.database.from(:songs).to_a
      expect(songs.size).to eql 2
    end
  end

  describe '.create_playlist' do
    before :all do
      songs = [{:name=>"Riptide",
                :artist=>"Vance Joy",
                :composer=>"",
                :album=>"God Loves You When You're Dancing",
                :genre=>"Indie",
                :bpm=>142,
                :size=>86304363,
                :time=>339,
                :year=>2013,
                :created_at=>Time.now(),
                :updated_at=>Time.now()
               },
               {:name=>"Can't Hold Us",
                :artist=>"Macklemore & Ryan Lewis",
                :composer=>"",
                :album=>"The Heist",
                :genre=>"Hip-Hop/Rap",
                :bpm=>151,
                :size=>6529378,
                :time=>258,
                :year=>2012,
                :created_at=>Time.now(),
                :updated_at=>Time.now()
               }]
      songs.each do |song|
        @app.database.from(:songs).insert(song)
      end
    end

    it 'new genre playlist' do
      # happy path
      @app.create_playlist("genre", "indie")
      playlist = @app.get_playlist("indie")
      expect(playlist.size).to eql 1
      expect(playlist.first[:name]).to eql "Riptide"
    end

    it 'new decades playlist' do
      # happy path
      @app.create_playlist("decade", "10's")
      playlist = @app.get_playlist("10's")
      expect(playlist.size).to eql 2
    end

    it 'recreates existing playlists' do
      playlist = @app.database.from(:playlists).where(playlist_name: "indie")
      old_id = playlist.select(:playlist_id).single_value
      @app.create_playlist("genre", "indie")
      # check that playlist has a new id
      new_id = playlist.select(:playlist_id).single_value
      expect(new_id != old_id)
    end

    it 'invalid decade' do
      expect{@app.create_playlist("decade", "nineties")}.to raise_error(RuntimeError)
    end

    it 'invalid genre' do
      expect{@app.create_playlist("genre", "&$*#@($")}.to raise_error(RuntimeError)
    end

    it 'invalid type' do
      expect{@app.create_playlist("invalid", "90's")}.to raise_error(RuntimeError)
    end
  end

  describe '.get_playlist' do
    it 'returns array of songs' do
      songs = @app.get_playlist("indie")
      expect(songs.size).to eql 1
      titles = songs.collect{|song| song[:name]}
      expect(titles).to eql ["Riptide"]
    end

    it 'non-existent playlist' do
      expect(@app.get_playlist("invalid").empty?).to eql true
    end
  end
end
