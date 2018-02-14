module CohortColumns
  class DaysHomelessLastThreeYears < Base
    attribute :column, String, lazy: true, default: :days_homeless_last_three_years
    attribute :title, String, lazy: true, default: 'Days Homeless in the last 3 years*'

    def default_input_type
      :read_only
    end

    def value(cohort_client)
      Rails.cache.fetch([cohort_client.client.id, 'days_homeless_last_three_years'], expires_at: 8.hours) do
        cohort_client.client.days_homeless_in_last_three_years(on_date: (cohort_client.cohort.effective_date || Date.today))
      end
    end

  end
end