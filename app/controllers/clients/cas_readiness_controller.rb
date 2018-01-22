module Clients
  class CasReadinessController < ApplicationController
    include ClientPathGenerator
    
    before_action :require_can_edit_clients!
    before_action :set_client

    def edit
      range = ::Filters::DateRange.new(start: 5.years.ago, end: Date.today)
      @enrollments = @client.source_enrollments.
        includes(:exit, project: :organization).
        homeless.
        open_during_range(range)
      @cas_enrollments = @client.cas_enrollments.index_by(&:enrollment_id)
    end
    
    def update
      update_params = cas_readiness_params
      if GrdaWarehouse::Config.get(:cas_flag_method).to_s != 'file'
        update_params[:disability_verified_on] = if update_params[:disability_verified_on] == '1'
          @client.disability_verified_on || Time.now
        else
          nil
        end
      end
      
      if @client.update(update_params)
        # Keep various client fields in sync with files if appropriate
        @client.sync_cas_attributes_with_files
        # Assign/update CAS APR assessments/enrollments as necessary
        cas_enrollment_params[:enrollments].each do |enrollment_id, dates|
          en = GrdaWarehouse::CasEnrollment.where(client_id: @client.id, enrollment_id: enrollment_id).first_or_initialize
          if en.persisted?
            en.update(dates)
          elsif dates[:entry_date].present?
            en.assign_attributes(dates)
            en.save
          end

        end
        flash[:notice] = 'Client updated'
        ::Cas::SyncToCasJob.perform_later
        redirect_to action: :edit
      else
        flash[:notice] = 'Unable to update client'
        render :edit
      end
    end

    protected

      def set_client
        @client = client_source.destination.find(params[:client_id].to_i)
      end

      def cas_readiness_params
        params.require(:readiness).permit(*client_source.cas_readiness_parameters)
      end

      def cas_enrollment_params
        params.require(:readiness).permit(
          enrollments: [:entry_date, :exit_date]
        )
      end

      def client_source
        GrdaWarehouse::Hud::Client
      end
  end
end
