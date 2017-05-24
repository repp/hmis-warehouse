module PublicDashboards::Rrh
  class TimeToHousingController < ApplicationController
    def index
      render layout: ! request.xhr?
    end
  end
end
