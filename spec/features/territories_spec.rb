require 'rails_helper'

RSpec.describe Territory, type: :request do
  include Warden::Test::Helpers

  describe "Territories pages: " do
    let(:te) {FactoryBot.create(:territory)}

    context "when not signed in " do
      it "should propose to log in when requesting index view" do
        get territories_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting new view" do
        get new_territory_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting edit view" do
        get edit_territory_path(te)
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting show view" do
        get territory_path(te)
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
        get territories_path
        expect(response).to render_template(:index)
      end
      it "should display new view" do
        get new_territory_path(territory_id: 0)
        expect(response).to render_template(:_form)
      end
      it "should display edit view" do
        get edit_territory_path(te)
        expect(response).to render_template(:_form)
      end
      it "should display show view" do
        get territory_path(te)
        expect(response).to render_template(:show)
      end
    end
  end
end
