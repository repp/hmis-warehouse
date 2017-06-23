# these are also sometimes called agencies
module GrdaWarehouse::Hud
  class Organization < Base
    self.table_name = 'Organization'
    self.hud_key = 'OrganizationID'
    acts_as_paranoid column: :DateDeleted
    has_many :projects, **hud_many(Project), inverse_of: :organization
    belongs_to :export, **hud_belongs(Export), inverse_of: :organizations
    belongs_to :data_source, inverse_of: :organizations
    has_many :service_histories, 
      class_name: 'GrdaWarehouse::ServiceHistory',
      foreign_key: [:data_source_id, :organization_id], primary_key: [:data_source_id, :OrganizationID],
      inverse_of: :organization
    has_many :contacts, class_name: GrdaWarehouse::Contact::Organization.name, foreign_key: :entity_id
    has_many :user_viewable_entities, as: :entity, class_name: 'GrdaWarehouse::Hud::UserViewableEntity'

    # NOTE: you need to add a distinct to this or group it to keep from getting repeats
    scope :residential, -> {
      joins(:projects).where(
        Project.arel_table[:ProjectType].in Project::RESIDENTIAL_PROJECT_TYPE_IDS
      )
    }
    scope :viewable_by, -> (user) do
      if user.roles.where( can_edit_anything_super_user: true ).exists?
        current_scope
      else
        uve_t = GrdaWarehouse::Hud::UserViewableEntity.arel_table
        o_t   = arel_table
        where(
          GrdaWarehouse::Hud::UserViewableEntity.where(
            uve_t[:user_id].eq(user.id).and(
              uve_t[:entity_id].eq(o_t[:id]).and( uve_t[:entity_type].eq sti_name ).or(
                uve_t[:entity_id].eq(o_t[:data_source_id]).and( uve_t[:entity_type].eq GrdaWarehouse::DataSource.sti_name )
              )
            )
          ).exists
        )
      end
    end

    def self.hud_csv_headers(version: nil)
      [
        "OrganizationID",
        "OrganizationName",
        "OrganizationCommonName",
        "DateCreated",
        "DateUpdated",
        "UserID",
        "DateDeleted",
        "ExportID"
      ]
    end

    # when we export, we always need to replace OrganizationID with the value of id
    def self.to_csv(scope:)
      attributes = self.hud_csv_headers
      headers = attributes.clone
      attributes[attributes.index('OrganizationID')] = 'id'


      CSV.generate(headers: true) do |csv|
        csv << headers

        scope.each do |i|
          csv << attributes.map{ |attr| i.send(attr) }
        end
      end
    end

    def self.names
      select(:OrganizationID, :OrganizationName).distinct.pluck(:OrganizationName, :OrganizationID)
    end

    alias_attribute :name, :OrganizationName

    def self.text_search(text)
      return none unless text.present?

      query = "%#{text}%"

      where(
        arel_table[:OrganizationName].matches(query)
      )
    end

  end
end