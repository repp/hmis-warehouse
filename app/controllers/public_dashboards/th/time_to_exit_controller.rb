module PublicDashboards::Th
  class TimeToExitController < ApplicationController
    def index
      render layout: ! request.xhr?
    end
  end
end
