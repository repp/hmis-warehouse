module WarehouseReports
  class CasDecisionEfficiencyController < ApplicationController
    before_action :require_can_view_reports!
    def index
      et = GrdaWarehouse::Hud::Enrollment.arel_table
      @clients = client_source.
        joins(:source_enrollments).
        preload(:source_enrollments).
        where( et[:EntryDate].gt(Date.today) ).
        order(:LastName, :FirstName).
        page(params[:page]).per(25)
    end

    # creates a histogram mapping intervals to numbers of occurrences
    private def step_time_histogram(first_step, second_step, unit=:day)
      divisor = case unit
      when :hour
        60 * 60
      when :day
        24 * 60 * 60
      else
        raise "unanticipated time unit: #{unit}"
      end
      at = GrdaWarehouse::CasReport.arel_table
      at2 = Arel::Table.new at.table_name
      at2.table_alias = 'at2'
      query = at.join(at2).on(
        at[:client_id].eq(at2[:client_id]).and(
          at[:match_id].eq at2[:match_id]
        ).and(
          at[:match_step].eq first_step
        ).and(
          at2[:match_step].eq second_step
        )
      ).project(
        seconds_diff( at.engine, at2[:updated_at], at[:updated_at] )
      )
      times = at.engine.connection.select_rows(query.to_sql).flatten.map(&:to_f).map{ |i| ( i / divisor ).round.to_i }
      min, max = times.minmax
      histogram = times.group_by(&:itself).map{ |v,ar| [ v, ar.length ] }.to_h
      (min..max).each{ |v| histogram[v] ||= 0 }
      histogram.sort_by(&:first).to_h
    end

    class StepRange < ModelForm
      attribute :first_step, String
      attribute :second_step, String

      # hash from steps to steps that may follow them
      def self.ordered_steps
        @ordered_steps ||= begin
          scope = GrdaWarehouse::CasReport
          steps = scope.uniq.order(:match_step).pluck :match_step
          at = scope.arel_table
          at2 = Arel::Table.new at.table_name
          at2.table_alias = 'at2'
          followups = steps.map do |step|
            followups = scope.where(
              at2.project(Arel.star).
                where( at2[:client_id].eq at[:client_id] ).
                where( at2[:match_id].eq at[:match_id] ).
                where( at2[:decision_order].lt at[:decision_order] ).
                where( at2[:match_step].eq step ).
                exists
            ).order(:match_step).distinct.pluck(:match_step)
            [ step, followups ]
          end
          followups.select{ |_,ar| ar.any? }.to_h
        end
      end

      def ordered_steps
        self.class.ordered_steps
      end
    end
  end
end