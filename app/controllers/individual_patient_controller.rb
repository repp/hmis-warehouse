class IndividualPatientController < HealthController
  before_action :require_some_patient_access!
  include WindowClientPathGenerator

end