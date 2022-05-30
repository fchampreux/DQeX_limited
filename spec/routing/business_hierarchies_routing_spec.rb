require "rails_helper"

RSpec.describe BusinessHierarchiesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/business_hierarchies").to route_to("business_hierarchies#index")
    end

    it "routes to #new" do
      expect(:get => "/business_hierarchies/new").to route_to("business_hierarchies#new")
    end

    it "routes to #show" do
      expect(:get => "/business_hierarchies/1").to route_to("business_hierarchies#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/business_hierarchies/1/edit").to route_to("business_hierarchies#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/business_hierarchies").to route_to("business_hierarchies#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/business_hierarchies/1").to route_to("business_hierarchies#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/business_hierarchies/1").to route_to("business_hierarchies#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/business_hierarchies/1").to route_to("business_hierarchies#destroy", :id => "1")
    end

  end
end
