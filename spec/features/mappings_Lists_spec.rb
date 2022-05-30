require 'rails_helper'

RSpec.describe MappingsList, type: :request do
  include Warden::Test::Helpers

  describe "Mappings Lists pages: " do
    let(:ml) {FactoryBot.create(:mappings_list)}

    context "when not signed in " do
      it "should propose to log in when requesting index view" do
        get mappings_lists_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting new view" do
        #get new_mappings_list_path(ml)
        #follow_redirect!
        #expect(response.status).to eq 401
        get new_mappings_list_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting edit view" do
        get edit_mappings_list_path(ml)
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting show view" do
        get mappings_list_path(ml)
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
        get mappings_lists_path
        expect(response).to render_template(:index)
      end
      it "should display new view" do
        get new_mappings_list_path(ml)
        expect(response).to render_template(:_form)
      end
      it "should display edit view" do
        get edit_mappings_list_path(ml)
        expect(response).to render_template(:_form)
      end
      it "should display show view" do
        get mappings_list_path(ml)
        expect(response).to render_template(:show)
      end
    end
  end
end
