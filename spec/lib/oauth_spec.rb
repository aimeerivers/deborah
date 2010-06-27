require File.dirname(__FILE__) + '/../spec_helper'

describe Oauth do
  describe 'getting request token from Google' do
    before do
      Connector.stub!(:post_request => {'oauth_token' => ['TOKEN'], 'oauth_token_secret' => ['SECRET']})
    end

    it 'makes a request to OAuthGetRequestToken' do
      Connector.should_receive(:post_request).with('https://www.google.com/accounts/OAuthGetRequestToken', anything)
      Oauth.get_request_token('example.org', 80)
    end

    it 'includes a callback URL' do
      Connector.should_receive(:post_request).with(anything, hash_including('oauth_callback' => 'http://myhost.com:5839/continue'))
      Oauth.get_request_token('myhost.com', 5839)
    end

    it 'returns the token and secret' do
      Oauth.get_request_token('example.org', 80).should == ['TOKEN', 'SECRET']
    end
  end

  describe 'getting access token from Google' do
    before do
      Connector.stub!(:post_request => {'oauth_token' => ['TOKEN'], 'oauth_token_secret' => ['SECRET']})
    end

    it 'makes a request to OAuthGetAccessToken' do
      Connector.should_receive(:post_request).with('https://www.google.com/accounts/OAuthGetAccessToken', anything, anything)
      Oauth.get_access_token(mock, mock, mock)
    end

    it 'includes the token and verifier in the request' do
      token, verifier = mock(:token), mock(:verifier)
      oauth = hash_including({
        'oauth_token' => token,
        'oauth_verifier' => verifier
      })
      Connector.should_receive(:post_request).with(anything, oauth, anything)
      Oauth.get_access_token(token, verifier, mock)
    end

    it 'signs the request with the secret token' do
      secret = mock(:secret)
      Connector.should_receive(:post_request).with(anything, anything, secret)
      Oauth.get_access_token(mock, mock, secret)
    end

    it 'returns the token and secret' do
      Oauth.get_access_token(mock, mock, mock).should == ['TOKEN', 'SECRET']
    end
  end
end
