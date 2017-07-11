module PublicDashboards::Es
  class TimeToExitController < PublicController
    def index
      render layout: ! request.xhr?
    end
  end
end
