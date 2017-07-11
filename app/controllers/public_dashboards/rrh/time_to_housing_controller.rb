module PublicDashboards::Rrh
  class TimeToHousingController < PublicController
    def index
      render layout: ! request.xhr?
    end
  end
end
