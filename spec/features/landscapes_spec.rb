require 'rails_helper'

RSpec.describe Landscape, type: :request do
  include Warden::Test::Helpers

  describe "Landscapes pages: " do
    let(:ls) {FactoryBot.create(:landscape)}

    context "when not signed in " do
      it "should propose to log in when requesting index view" do
        get landscapes_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting new view" do
        #get new_landscape_path(ls)
        #follow_redirect!
        #expect(response.status).to eq 401
        get new_landscape_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting edit view" do
        get edit_landscape_path(ls)
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting show view" do
        get landscape_path(ls)
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
        get landscapes_path
        expect(response).to render_template(:index)
      end
      it "should display new view" do
        get new_landscape_path(ls)
        expect(response).to render_template(:_form)
      end
      it "should display edit view" do
        get edit_landscape_path(ls)
        expect(response).to render_template(:_form)
      end
      it "should display show view" do
        get landscape_path(ls)
        expect(response).to render_template(:show)
      end
    end

  end
end
