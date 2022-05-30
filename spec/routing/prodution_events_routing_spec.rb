require "rails_helper"

RSpec.describe ProdutionEventsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/prodution_events").to route_to("prodution_events#index")
    end

    it "routes to #new" do
      expect(get: "/prodution_events/new").to route_to("prodution_events#new")
    end

    it "routes to #show" do
      expect(get: "/prodution_events/1").to route_to("prodution_events#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/prodution_events/1/edit").to route_to("prodution_events#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/prodution_events").to route_to("prodution_events#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/prodution_events/1").to route_to("prodution_events#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/prodution_events/1").to route_to("prodution_events#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/prodution_events/1").to route_to("prodution_events#destroy", id: "1")
    end
  end
end
