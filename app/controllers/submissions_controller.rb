class SubmissionsController < ApplicationController
  include Knock::Authenticable
  before_action :authenticate_user

  def create
    check = current_user.checks.find(submission_params[:check_id])
    check.submissions.create!(submission_params)
  end

  private

  def submission_params
    params.require(:submission).permit(:check_id, :zip_file)
  end
end
