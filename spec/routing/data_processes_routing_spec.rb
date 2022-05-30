require "spec_helper"

describe DataProcessesController do
  describe "routing" do

    it "routes to #index" do
      get("/data_processes").should route_to("data_processes#index")
    end

    it "routes to #new" do
      get("/data_processes/new").should route_to("data_processes#new")
    end

    it "routes to #show" do
      get("/data_processes/1").should route_to("data_processes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/data_processes/1/edit").should route_to("data_processes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/data_processes").should route_to("data_processes#create")
    end

    it "routes to #update" do
      put("/data_processes/1").should route_to("data_processes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/data_processes/1").should route_to("data_processes#destroy", :id => "1")
    end

  end
end
