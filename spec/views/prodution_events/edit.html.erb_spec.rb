require 'rails_helper'

RSpec.describe "prodution_events/edit", type: :view do
  before(:each) do
    @prodution_event = assign(:prodution_event, ProdutionEvent.create!())
  end

  it "renders the edit prodution_event form" do
    render

    assert_select "form[action=?][method=?]", prodution_event_path(@prodution_event), "post" do
    end
  end
end
