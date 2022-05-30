require 'rails_helper'

RSpec.describe "prodution_jobs/index", type: :view do
  before(:each) do
    assign(:prodution_jobs, [
      ProdutionJob.create!(),
      ProdutionJob.create!()
    ])
  end

  it "renders a list of prodution_jobs" do
    render
  end
end
