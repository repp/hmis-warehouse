module PublicApi
  class NewClientsController < ApplicationController
    # New clients (first time homeless) for public dashboard
    def index
      new_clients = {}

      #New clients a year ago
      start_date = 13.months.ago.beginning_of_month.to_date
      end_date = start_date.end_of_month
      @range = DateRange.new(start: start_date, end: end_date)

      @clients = client_source

      @clients = @clients.entered_in_range(@range.range)

      #TODO Filtering by project_type
      # @project_types = params.try(:[], :first_time_homeless).try(:[], :project_types) || []
      # @project_types.reject!(&:empty?)
      # if @project_types.any?
      #   @project_types.map!(&:to_i)
      #   @clients = @clients.where(history.table_name => {project_type: @project_types})
      # end

      new_clients[start_date.to_time.strftime('%b %Y')] = @clients.select(:id).distinct.count

      #New clients last month
      start_date = 1.months.ago.beginning_of_month.to_date
      end_date = start_date.end_of_month
      @range = DateRange.new(start: start_date, end: end_date)

      @clients = client_source

      @clients = @clients.entered_in_range(@range.range)

      # @project_types = params.try(:[], :first_time_homeless).try(:[], :project_types) || []
      # @project_types.reject!(&:empty?)
      # if @project_types.any?
      #   @project_types.map!(&:to_i)
      #   @clients = @clients.where(history.table_name => {project_type: @project_types})
      # end

      new_clients[start_date.to_time.strftime('%b %Y')] = @clients.select(:id).distinct.count

      respond_to do |format|
        format.json do
          render json: new_clients
        end
      end
    end
    private def history
      GrdaWarehouse::ServiceHistory
    end

    private def client_source
      GrdaWarehouse::Hud::Client.destination
    end
  end
end
