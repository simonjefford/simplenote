require 'httparty'
require 'base64'
require 'crack'

require File.join(File.expand_path('..', __FILE__), 'simplenote_api2')

class SimpleNote
  include HTTParty
  attr_reader :token, :email
  format :json
  base_uri 'https://simple-note.appspot.com/api'

  def login(email, password)
    encoded_body = Base64.encode64({:email => email, :password => password}.to_params)
    @email = email
    @token = self.class.post "/login", :body => encoded_body
    raise "Login failed" unless @token.response.is_a?(Net::HTTPOK)
  end

  def get_index
    self.class.get "/index", :query => request_hash, :format => :json
  end

  def get_note(key)
    out = self.class.get "/note", :query => request_hash.merge(:key => key), :format => :plain
    out.response.is_a?(Net::HTTPNotFound) ? nil : out
  end

  def delete_note(key)
    out = self.class.get "/delete", :query => request_hash.merge(:key => key)
    raise "Couldn't delete note" unless out.response.is_a?(Net::HTTPOK)
    out
  end

  def update_note(key, content)
    self.class.post "/note", :query => request_hash.merge(:key => key), :body => Base64.encode64(content)
  end
  
  def create_note(content)
    self.class.post "/note", :query => request_hash, :body => Base64.encode64(content)
  end

  def search(search_string, max_results=10)
    self.class.get "/search", :query => request_hash.merge(:query => search_string, :results => max_results)
  end

  private

  def request_hash
    { :auth => token, :email => email }
  end
end
