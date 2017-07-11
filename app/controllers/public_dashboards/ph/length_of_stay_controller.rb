module PublicDashboards::Ph
  class LengthOfStayController < PublicController
    def index
      render layout: ! request.xhr?
    end
  end
end
