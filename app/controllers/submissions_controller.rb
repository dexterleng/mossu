class SubmissionsController < ApplicationController
  def create
    Submission.create!(submission_params)
  end

  private

  def submission_params
    params.require(:submission).permit(:check_id, :zip_file)
  end
end
