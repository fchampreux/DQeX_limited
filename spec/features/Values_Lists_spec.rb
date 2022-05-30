require 'rails_helper'

RSpec.describe ValuesList, type: :request do
  include Warden::Test::Helpers

  describe "Values Lists pages: " do
    let(:vl) {FactoryBot.create(:values_list)}

    context "when not signed in " do
      it "should propose to log in when requesting index view" do
        get values_lists_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting new view" do
        get new_values_list_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting edit view" do
        get edit_values_list_path(vl)
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting show view" do
        get values_list_path(vl)
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
        get values_lists_path
        expect(response).to render_template(:index)
      end
      it "should display new view" do
        get new_values_list_path(business_area_id: vl.parent.id)
        expect(response).to render_template(:_form)
      end
      it "should display edit view" do
        get edit_values_list_path(vl)
        expect(response).to render_template(:_form)
      end
      it "should display show view" do
        get values_list_path(vl)
        expect(response).to render_template(:show)
      end
    end
  end
end
