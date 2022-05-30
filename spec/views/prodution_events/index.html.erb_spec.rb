require 'rails_helper'

RSpec.describe "prodution_events/index", type: :view do
  before(:each) do
    assign(:prodution_events, [
      ProdutionEvent.create!(),
      ProdutionEvent.create!()
    ])
  end

  it "renders a list of prodution_events" do
    render
  end
end
