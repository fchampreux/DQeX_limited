require 'rails_helper'

describe "Static pages : " do

  subject { page }

### PAGE1 to test that Home Page has header and title
  describe "Home" do
    before { visit root_path }

    it { should have_selector('h1',    text: 'Welcome') }
    it { should have_title('Home') }

  end

### PAGE2 to test that About Page has header and title
  describe "About" do
    before { visit '/about' }

    it { should have_selector('h1',    text: 'What is') }
    it { should have_title('About') }

  end

### PAGE3 to test that Help Page has header and title
  describe "Help" do
    before { visit '/help'}

    it { should have_selector('h1',    text: 'Help') }
    it { should have_title('Help') }

  end

### PAGE4 to test that Contact Page has header and title
  describe "Contact" do
    before { visit '/contact' }

    it { should have_selector('h1',    text: 'Contact') }
    it { should have_title('Contact') }

  end
end

