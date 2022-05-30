require 'rails_helper'

RSpec.describe "prodution_jobs/show", type: :view do
  before(:each) do
    @prodution_job = assign(:prodution_job, ProdutionJob.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
