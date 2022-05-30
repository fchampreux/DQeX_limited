require 'rails_helper'

RSpec.describe "prodution_jobs/edit", type: :view do
  before(:each) do
    @prodution_job = assign(:prodution_job, ProdutionJob.create!())
  end

  it "renders the edit prodution_job form" do
    render

    assert_select "form[action=?][method=?]", prodution_job_path(@prodution_job), "post" do
    end
  end
end
