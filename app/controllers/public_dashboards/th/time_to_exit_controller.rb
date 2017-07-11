module PublicDashboards::Th
  class TimeToExitController < PublicController
    def index
      render layout: ! request.xhr?
    end
  end
end
