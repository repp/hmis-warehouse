module PublicApi::Pit
  class ShelteredHomelessCountController < PublicController
    CACHE_EXPIRY = if Rails.env.production? then 8.hours else 2.minutes end
    ON_DATE = '2017-01-25'

    #One day count of all sheltered homeless on a specific date (1/25/2017)
    def index
      data = Rails.cache.fetch('ShelteredHomelessCount', expires_in: CACHE_EXPIRY) do
        sh_count = calculate_sheltered_counts()
        category_count = calculate_sh_counts_by_category(sh_count)

        {
          sheltered_count: sh_count,
          category_count: category_count
        }
      end

      respond_to do |format|
        format.json do
          render json: data
        end
      end
    end

    def calculate_sheltered_counts
        GrdaWarehouse::ServiceHistory.service.where(date: ON_DATE).where(
          project_type: GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPE_IDS
        ).group(:project_type).
        pluck('project_type, count(distinct(client_id))').

        map do |project_type, count|
          [
            project_type,
            {
              count: count,
              project_type: ::HUD.project_type(project_type),
            }
          ]
        end.to_h
    end

    def calculate_sh_counts_by_category(sh_count)
      sh_count_by_category = {}
      GrdaWarehouse::Hud::Project::PROJECT_TYPE_TITLES.each do |pt, title|
        sh_count_by_category[pt] = {count: 0, project_type: title}
        sh_count_by_category[pt][:count] = sh_count.select do |project_type, data|
          GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPES[pt].include?(project_type)
        end.map{|_, data| data[:count]}.sum
      end
      return sh_count_by_category
      #map {|k, v| [::HUD.project_type(k), v] }.to_h
    end

  end
end
