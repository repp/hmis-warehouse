module PublicDashboards
  class NewClientsController < ApplicationController
    #Clients served for public dashboard
    def index
      render layout: ! request.xhr?
    end
  end
end
