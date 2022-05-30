require 'rails_helper'

RSpec.describe "prodution_events/show", type: :view do
  before(:each) do
    @prodution_event = assign(:prodution_event, ProdutionEvent.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
