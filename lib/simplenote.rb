require 'httparty'
require 'base64'
require 'crack'

class SimpleNote
  include HTTParty
  attr_reader :token, :email
  base_uri 'https://simple-note.appspot.com/api'

  def login(email, password)
    encoded_body = Base64.encode64({:email => email, :password => password}.to_params)
    @email = email
    @token = self.class.post "/login", :body => encoded_body
  end

  def get_index
    self.class.get "/index", :query => { :auth => token, :email => email }, :format => :json
  end

  def get_note(key)
    self.class.get "/note", :query => { :key => key, :auth => token, :email => email }
  end
end
