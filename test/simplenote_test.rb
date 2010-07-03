require 'test_helper'

class SimpleNoteTest < Test::Unit::TestCase
  context "login" do
    setup do
      SimpleNote.stubs(:post).returns("token")
      @simplenote = SimpleNote.new
      @email = "validaccount@example.com"
      @password = "correctpassword"
      @simplenote.login(@email, @password)
    end

    should "store the returned token" do
      @simplenote.token.should == "token"
    end

    should "store the email" do
      @simplenote.email.should == @email
    end

    should "post to /login with email and password base 64 encoded" do
      expected_body = Base64.encode64({ :email => @email, :password => @password}.to_params)
      assert_received(SimpleNote, :post) do |expect|
        expect.with "/login", :body => expected_body
      end
    end
  end
  
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
  end

  should_eventually "raise when login fails"

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
