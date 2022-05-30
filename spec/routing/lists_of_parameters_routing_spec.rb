require "spec_helper"

describe ListsOfParametersController do
  describe "routing" do

    it "routes to #index" do
      get("/lists_of_parameters").should route_to("lists_of_parameters#index")
    end

    it "routes to #new" do
      get("/lists_of_parameters/new").should route_to("lists_of_parameters#new")
    end

    it "routes to #show" do
      get("/lists_of_parameters/1").should route_to("lists_of_parameters#show", :id => "1")
    end

    it "routes to #edit" do
      get("/lists_of_parameters/1/edit").should route_to("lists_of_parameters#edit", :id => "1")
    end

    it "routes to #create" do
      post("/lists_of_parameters").should route_to("lists_of_parameters#create")
    end

    it "routes to #update" do
      put("/lists_of_parameters/1").should route_to("lists_of_parameters#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/lists_of_parameters/1").should route_to("lists_of_parameters#destroy", :id => "1")
    end

  end
end
