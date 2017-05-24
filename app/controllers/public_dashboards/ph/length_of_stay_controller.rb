module PublicDashboards::Ph
  class LengthOfStayController < ApplicationController
    def index
      render layout: ! request.xhr?
    end
  end
end
