module WarehouseReports::Cas
  class AprController < ApplicationController
    include ArelHelper
    include WarehouseReportAuthorization
    before_action :set_range

    def index
      @missing = GrdaWarehouse::Hud::Client.cas_active.
        where.not(
          id: GrdaWarehouse::CasEnrollment.distinct.select(:client_id)
        )
      @cas_enrollments = GrdaWarehouse::CasEnrollment.
        open_between(start_date: @range.start, end_date: @range.end).
        joins(:client, :enrollment)
    end

    def set_range
      date_range_options = params.permit(range: [:start, :end])[:range]
      unless date_range_options.present?
        date_range_options = {
          start: 13.month.ago.to_date,
          end: 1.months.ago.to_date,
        }
      end
      @range = ::Filters::DateRange.new(date_range_options)
    end

    def report_source
      GrdaWarehouse::CasReport
    end

  end
end
