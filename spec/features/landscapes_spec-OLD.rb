require 'rails_helper'

describe "Landscapes pages: " do

  subject { page }

### LANDSCAPE1 to test that Landscape Page has header and title only when signed-in
  describe "when not signed_in " do

    describe "page" do
      before { visit landscapes_path }

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
      before { visit landscapes_path }

      it { should have_selector('h1', text: 'Landscapes') }
      it { should have_title('Managing landscapes') }
      it { should have_content('New Landscape') }
    end
  end

end
