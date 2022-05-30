require 'rails_helper'

RSpec.describe "prodution_events/new", type: :view do
  before(:each) do
    assign(:prodution_event, ProdutionEvent.new())
  end

  it "renders new prodution_event form" do
    render

    assert_select "form[action=?][method=?]", prodution_events_path, "post" do
    end
  end
end
