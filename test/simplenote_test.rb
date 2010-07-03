require 'test_helper'

class SimpleNoteTest < Test::Unit::TestCase
  context SimpleNote do
    should "log in, list notes and fetch a note" do
      VCR.use_cassette('get_index', :record => :none) do
        simplenote = SimpleNote.new
        simplenote.login("simplenotetest@mailinator.com", "password!")

        notes = simplenote.get_index
        assert_equal 1, notes.length
        assert !notes.first["deleted"]
        assert_equal "2010-07-03 22:41:13.721231", notes.first["modify"]
        assert_equal "agtzaW1wbGUtbm90ZXINCxIETm90ZRiD1LoCDA", notes.first["key"]
        
        note = simplenote.get_note(notes.first["key"])
        assert_equal "hello world this is a new note", note.parsed_response
      end
    end
    
    should "search notes" do
      VCR.use_cassette('search', :record => :none) do
        simplenote = SimpleNote.new
        simplenote.login("simplenotetest@mailinator.com", "password!")
        
        response = simplenote.search("hello")
        assert_equal 1, response["Response"]["Results"].length
        assert_equal "agtzaW1wbGUtbm90ZXINCxIETm90ZRiD1LoCDA", response["Response"]["Results"].first["key"]
        
        response = simplenote.search("goodbye")
        assert_equal 0, response["Response"]["Results"].length
      end
    end
    
    should "raise when login fails" do
      VCR.use_cassette('login_failure', :record => :none) do
        simplenote = SimpleNote.new
        
        error = assert_raises RuntimeError do
          simplenote.login("simplenotetest@mailinator.com", "not my password!")
        end
        assert_equal "Login failed", error.message
      end
    end
    
    should "create, list, fetch and delete a note" do
      VCR.use_cassette('create_note', :record => :none) do
        simplenote = SimpleNote.new
        simplenote.login("simplenotetest@mailinator.com", "password!")
        
        response = simplenote.create_note("A test note")
        key = response.parsed_response
        
        notes = simplenote.get_index
        assert_contains notes.collect { |note| note["key"] }, key
        
        note = simplenote.get_note(key)
        assert_equal "A test note", note.parsed_response
        
        simplenote.delete_note(key)
      end
    end
    
    should_eventually "return nil when a note doesn't exist"
    should_eventually "raise if you try to delete a note that doesn't exist"
  end

  context "get_index" do
    setup do
      # TODO - test helper to construct urls given a SimpleNote object
      @url = "https://simple-note.appspot.com/api/index?email=me%40example.com&auth=token"
      body = '[{"key":"notekey", "modify":"2009-09-02 12:00:00.000000", "key":"AB1234"}]'
      FakeWeb.register_uri(:get, @url, :body => body)
      @simplenote = SimpleNote.new
      @simplenote.stubs(:token).returns("token")
      @simplenote.stubs(:email).returns("me@example.com")
      @index = @simplenote.get_index
    end
    
    should "return an Array" do
      @index.should be_kind_of(Array)
    end

    context "returned array" do
      should "contain a single Hash" do
        @index.length.should == 1
        @index[0].should be_kind_of(Hash)
      end
    end
  end
end
