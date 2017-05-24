module PublicDashboards
  class ClientsServedController < ApplicationController
    #Clients served for public dashboard
    def index
      render layout: ! request.xhr?
    end
  end
end
