require 'rails_helper'

RSpec.describe Scope, type: :request do
  include Warden::Test::Helpers

  describe "Business Areas pages: " do
    let(:sc) {FactoryBot.create(:scope)}

    context "when not signed in " do
      it "should propose to log in when requesting index view" do
        get scopes_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting new view" do
        get new_scope_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting edit view" do
        get edit_scope_path(sc)
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting show view" do
        get scope_path(sc)
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
        get scopes_path
        expect(response).to render_template(:index)
      end
      it "should display new view" do
        get new_scope_path(business_object_id: sc.parent.id)
        expect(response).to render_template(:_form)
      end
      it "should display edit view" do
        get edit_scope_path(sc)
        expect(response).to render_template(:_form)
      end
      it "should display show view" do
        get scope_path(sc)
        expect(response).to render_template(:show)
      end
    end

  end
end
