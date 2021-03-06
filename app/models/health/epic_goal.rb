module Health
  class EpicGoal < Base
    belongs_to :patient, primary_key: :id_in_source, foreign_key: :patient_id, inverse_of: :epic_goals

    scope :visible, -> do
      where(arel_table[:title].matches('SDH%'))
    end

    self.source_key = :GOAL_ID
    
    def self.csv_map(version: nil)
      {
        PAT_ID: :patient_id,
        GOAL_ID: :id_in_source,
        goal_created: :goal_created_at,
        entered_by: :entered_by,
        title: :title,
        contents: :contents,
        REC_VAL_COMPLIAN_YN: :received_valid_complaint,
        row_created: :created_at,
        row_updated: :updated_at,
      }
    end

    def objective
      part(:objective)
    end
    def steps
      part(:steps)
    end
    def team
      part(:team)
    end

    def part(section)
      objective = 'Objective:'
      steps = 'Steps to reach goal:'
      team = 'Team members contributing to achieve goal:'
      @parts ||= {
        objective: contents.match(/#{objective} +(.+?)  #{steps}/).try(:[], 1),
        steps: contents.match(/#{steps} +(.+?)  #{team}/).try(:[], 1),
        team: contents.match(/#{team} +(.+?)  /).try(:[], 1),
      }
      @parts[section]
    end

  end
end