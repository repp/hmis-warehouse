module PublicDashboards::Pit
  class ShelteredHomelessCountController < ApplicationController
    #One day count of all sheltered homeless on a specific date (1/25/2017)
    def index
      render layout: ! request.xhr?
    end
  end
end
