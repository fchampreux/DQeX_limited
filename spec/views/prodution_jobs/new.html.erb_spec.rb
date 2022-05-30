require 'rails_helper'

RSpec.describe "prodution_jobs/new", type: :view do
  before(:each) do
    assign(:prodution_job, ProdutionJob.new())
  end

  it "renders new prodution_job form" do
    render

    assert_select "form[action=?][method=?]", prodution_jobs_path, "post" do
    end
  end
end
