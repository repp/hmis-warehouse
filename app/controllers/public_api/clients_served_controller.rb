module PublicApi
  class ClientsServedController < ApplicationController
    #Clients served for public dashboard
    def index
      clients_served = {}

      start_date = 13.months.ago.beginning_of_month.to_date
      clients_served[start_date.to_time.strftime('%m-%Y')] = GrdaWarehouse::ServiceHistory.
          service_within_date_range(
            start_date: start_date,
            end_date: start_date.end_of_month
          ).select(:client_id).distinct.count

      start_date = 1.months.ago.beginning_of_month.to_date
      clients_served[start_date.to_time.strftime('%m-%Y')] = GrdaWarehouse::ServiceHistory.
          service_within_date_range(
            start_date: start_date,
            end_date: start_date.end_of_month
          ).select(:client_id).distinct.count

      respond_to do |format|
        format.json do
          render json: clients_served
        end
      end
    end
  end
end
