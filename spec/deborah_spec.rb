require File.dirname(__FILE__) + '/spec_helper'

describe "Deborah" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  describe 'home page' do
    context 'when not authenticated' do
      it 'renders the page' do
        get '/'
        last_response.should be_ok
      end
    end
  end

  describe 'login page' do
    it 'gets a request token from Google' do
      Oauth.should_receive(:get_request_token).with('example.org', 80)
      get '/login'
    end

    it 'redirects to Google for the user to login' do
      token = mock(:token)
      Oauth.stub!(:get_request_token).and_return([token, mock(:secret)])
      get '/login'
      last_response.should be_redirect
      redirect = last_response.original_headers['Location']
      redirect.should == "https://www.google.com/accounts/OAuthAuthorizeToken?oauth_token=#{token}"
    end
  end

  describe 'continuing login page' do
    it 'upgrades to a permanent access token from Google' do
      token, verifier = 'TOKEN', 'VERIFIER'
      Oauth.should_receive(:get_access_token).with(token, verifier, anything)
      get '/continue', :oauth_token => token, :oauth_verifier => verifier
    end

    it 'redirects to contacts page' do
      Oauth.stub!(:get_access_token)
      get '/continue'
      last_response.should be_redirect
      last_response.original_headers['Location'].should == '/contacts'
    end
  end

  describe 'logout page' do
    it 'redirects to the home page' do
      get '/logout'
      last_response.should be_redirect
      last_response.original_headers['Location'].should == '/'
    end
  end
end
