require 'test_helper'

class SimpleNoteTest < Test::Unit::TestCase
  context SimpleNote do
    setup do
      @simplenote = SimpleNote.new
    end

    should "log in, list notes and fetch a note" do
      VCR.use_cassette('get_index', :record => :none) do
        login()

        notes = @simplenote.get_index
        assert_equal 1, notes.length
        assert !notes.first["deleted"]
        assert_equal "2010-07-03 22:41:13.721231", notes.first["modify"]
        assert_equal "agtzaW1wbGUtbm90ZXINCxIETm90ZRiD1LoCDA", notes.first["key"]
        
        note = @simplenote.get_note(notes.first["key"])
        assert_equal "hello world this is a new note", note.parsed_response
      end
    end
    
    should "search notes" do
      VCR.use_cassette('search', :record => :none) do
        login
        
        response = @simplenote.search("hello")
        assert_equal 1, response["Response"]["Results"].length
        assert_equal "agtzaW1wbGUtbm90ZXINCxIETm90ZRiD1LoCDA", response["Response"]["Results"].first["key"]
        
        response = @simplenote.search("goodbye")
        assert_equal 0, response["Response"]["Results"].length
      end
    end
    
    should "raise when login fails" do
      VCR.use_cassette('login_failure', :record => :none) do
        @simplenote = SimpleNote.new
        
        error = assert_raises RuntimeError do
          @simplenote.login("simplenotetest@mailinator.com", "not my password!")
        end
        assert_equal "Login failed", error.message
      end
    end
    
    should "create, list, fetch and delete a note" do
      VCR.use_cassette('create_note', :record => :none) do
        login
        
        response = @simplenote.create_note("A test note")
        key = response.parsed_response
        
        notes = @simplenote.get_index
        assert_contains notes.collect { |note| note["key"] }, key
        
        note = @simplenote.get_note(key)
        assert_equal "A test note", note.parsed_response
        
        @simplenote.delete_note(key)
      end
    end
    
    should "return nil when you fetch a note that doesn't exist" do
      VCR.use_cassette('get_note_with_bad_key', :record => :none) do
        login
        
        assert_nil @simplenote.get_note("key that doesn't exist")
      end
    end
    
    should "raise if you try to delete a note that doesn't exist" do
      VCR.use_cassette('delete_note_with_bad_key', :record => :none) do
        login
        
        error = assert_raises RuntimeError do
          @simplenote.delete_note("key that doesn't exist")
        end
        assert_equal "Couldn't delete note", error.message
      end
    end
  end

  def login
    @simplenote.login("simplenotetest@mailinator.com", "password!")
  end
end
