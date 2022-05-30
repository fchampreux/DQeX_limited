require 'rails_helper'

RSpec.describe Skill, type: :request do
  include Warden::Test::Helpers

  describe "Skills pages: " do
    let(:sk) {FactoryBot.create(:skill)}

    context "when not signed in " do
      it "should propose to log in when requesting index view" do
        get skills_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting new view" do
        get new_skill_path
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting edit view" do
        get edit_skill_path(sk)
        follow_redirect!
        expect(response.body).to include('Sign in')
      end
      it "should propose to log in when requesting show view" do
        get skill_path(sk)
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
        get skills_path
        expect(response).to render_template(:index)
      end
      it "should display new view" do
        get new_skill_path(business_object_id: sk.parent.id)
        expect(response).to render_template(:_form)
      end
      it "should display edit view" do
        get edit_skill_path(sk)
        expect(response).to render_template(:_form)
      end
      it "should display show view" do
        get skill_path(sk)
        expect(response).to render_template(:show)
      end
    end
  end
end
