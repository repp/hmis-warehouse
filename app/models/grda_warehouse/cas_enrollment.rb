module GrdaWarehouse
  class CasEnrollment < GrdaWarehouseBase
    belongs_to :client, class_name: GrdaWarehouse::Hud::Client.name, autosave: false
    belongs_to :enrollment, class_name: GrdaWarehouse::Hud::Enrollment.name, autosave: false

    scope :open_between, -> (start_date:, end_date:) do 
      at = arel_table
      # Excellent discussion of why this works:
      # http://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
      d_1_start = start_date
      d_1_end = end_date
      d_2_start = at[:entry_date]
      d_2_end = at[:exit_date]
      # Currently does not count as an overlap if one starts on the end of the other
      where(d_2_end.gteq(d_1_start).or(d_2_end.eq(nil)).and(d_2_start.lteq(d_1_end)))
    end
  end
end