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

    context 'when authenticated' do
      it 'redirects to the contacts page' do
        ControllerHelper.stub!(:authenticated? => true)
        get '/'
        last_response.should be_redirect
      end
    end
  end
end
