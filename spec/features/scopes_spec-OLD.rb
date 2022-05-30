require 'rails_helper'

describe "Scopes pages: " do

  subject { page }

### SCOPE1 to test that Scope Page has header and title only when signed-in
  describe "when not signed_in " do

    describe "page" do
      before { visit scopes_path }

      it {should have_content('sign in')}
    end
  end

  describe "when signed_in" do
      before { visit signin_path }
      let(:user) { FactoryBot.create(:user) }
      before do
        fill_in "Login",    with: user.login
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

    describe "Page" do
      before { visit scopess_path }

      it { should have_selector('h1', text: 'Scopes') }
      it { should have_title('Managing scopess') }
      it { should have_content('New Scope') }
    end
  end

end
