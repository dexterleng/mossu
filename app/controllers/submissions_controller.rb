class SubmissionsController < ApplicationController
  include Knock::Authenticable
  before_action :authenticate_user

  def create
    check = current_user.checks.find(submission_params[:check_id])

    return render json: {}, status: 400 unless check.created?

    submission = check.submissions.create(submission_params)
    if submission.save
      render json: {}
    else
      render :json => { :errors => submission.errors.full_messages }, :status => 422
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:check_id, :zip_file)
  end
end
