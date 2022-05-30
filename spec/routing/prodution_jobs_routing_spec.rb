require "rails_helper"

RSpec.describe ProdutionJobsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/prodution_jobs").to route_to("prodution_jobs#index")
    end

    it "routes to #new" do
      expect(get: "/prodution_jobs/new").to route_to("prodution_jobs#new")
    end

    it "routes to #show" do
      expect(get: "/prodution_jobs/1").to route_to("prodution_jobs#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/prodution_jobs/1/edit").to route_to("prodution_jobs#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/prodution_jobs").to route_to("prodution_jobs#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/prodution_jobs/1").to route_to("prodution_jobs#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/prodution_jobs/1").to route_to("prodution_jobs#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/prodution_jobs/1").to route_to("prodution_jobs#destroy", id: "1")
    end
  end
end
