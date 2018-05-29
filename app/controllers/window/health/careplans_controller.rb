module Window::Health
  class CareplansController < ApplicationController
    include PjaxModalController
    include HealthPatient
    include WindowClientPathGenerator
    

    before_action :require_can_edit_client_health!
    before_action :set_client
    before_action :set_patient
    before_action :set_careplan, only: [:show, :edit, :update, :revise, :destroy]
    
    def index
      @goal = Health::Goal::Base.new
      @readonly = false
      @careplans = @patient.careplans
    end

    def show
      @goal = Health::Goal::Base.new
      @readonly = false
      file_name = 'care_plan'
      
      # debugging
      # render layout: false
      render pdf: file_name, layout: false, encoding: "UTF-8", page_size: 'Letter'
    end

    def edit
      @form_url = polymorphic_path(careplan_path_generator)
      @form_button = 'Save Care Plan'
    end

    def new
      Health::Careplan.transaction do
        @careplan = @patient.careplans.create!(user: current_user)
        @careplan.ensure_team_exists
      end
      redirect_to polymorphic_path([:edit] + careplan_path_generator, id: @careplan)
      # @form_url = polymorphic_path(careplans_path_generator)
      # @form_button = 'Create Care Plan'
    end

    def destroy
      @careplan.destroy
      respond_with(@careplan, location: polymorphic_path(careplans_path_generator))
    end

    def print
      @readonly = true
    end

    def revise
      new_id = @careplan.revise!
      flash[:notice] = "Careplan revised"
      redirect_to polymorphic_path([:edit] + careplan_path_generator, id: new_id)
    end

    def update
      attributes = careplan_params
      attributes[:user_id] = current_user.id
      @careplan.class.transaction do
        @careplan.update(attributes)
        @careplan.set_lock
      end
      # for errors
      @form_url = polymorphic_path(careplan_path_generator) 
      @form_button = 'Save Care Plan'
      
      respond_with(@careplan, location: polymorphic_path(careplans_path_generator))
    end

    def self_sufficiency_assessment
      @assessment = @client.self_sufficiency_assessments.last
    end
    
    def set_careplan
      @careplan = careplan_source.find(params[:id].to_i)
    end

    def careplan_source
      Health::Careplan
    end
    
    def careplan_params
      params.require(:health_careplan).
        permit(
          :initial_date,
          :review_date,
          :patient_signed_on,
          :provider_signed_on,
          :case_manager_id,
          :responsible_team_member_id,
          :responsible_team_member_signed_on,
          :representative_id,
          :representative_signed_on,
          :provider_id,
          :provider_signed_on,
          :patient_health_problems,
          :patient_strengths,
          :patient_goals,
          :patient_barriers,
        )
    end

    def flash_interpolation_options
      { resource_name: 'Care Plan' }
    end

  end
end