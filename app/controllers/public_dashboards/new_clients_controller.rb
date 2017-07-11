module PublicDashboards
  class NewClientsController < PublicController
    #Clients served for public dashboard
    def index
      render layout: ! request.xhr?
    end
  end
end
