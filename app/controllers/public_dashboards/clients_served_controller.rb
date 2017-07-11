module PublicDashboards
  class ClientsServedController < PublicController
    #Clients served for public dashboard
    def index
      render layout: ! request.xhr?
    end
  end
end
