require 'rails_helper'

RSpec.describe Playground, type: :request do
  include Warden::Test::Helpers

  describe "Playground pages: " do
    let(:pg) {FactoryBot.create(:playground)}

    context "when not signed in " do
      it "should propose to log in when requesting index" do
        get playgrounds_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting new" do
        #get new_playground_path(pg)
        #follow_redirect!
        #expect(response.status).to eq 401
        get new_playground_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting edit" do
        get edit_playground_path(pg)
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting show" do
        get playground_path(pg)
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
    end
    context "when signed in" do
      before do
        get "/users/sign_in"
        test_user = FactoryBot.create(:user)
        login_as test_user, scope: :user
      end
      it "should display index" do
        get playgrounds_path
        expect(response).to render_template(:index)
      end
      it "should display new view" do
        get new_playground_path(pg)
        expect(response).to render_template(:_form)
      end
      it "should display edit view" do
        get edit_playground_path(pg)
        expect(response).to render_template(:_form)
      end
      it "should display show view" do
        get playground_path(pg)
        expect(response).to render_template(:show)
      end
    end
  end
end
