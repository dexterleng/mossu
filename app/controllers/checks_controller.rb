class ChecksController < ApplicationController
  include Knock::Authenticable
  before_action :authenticate_user

  def index
    ids = checks_params[:id]
    if ids.is_a?(Array)
      checks = current_user.checks.find(ids)
      render json: checks
      return
    end

    checks = current_user.checks.order(:created_at)
    render json: checks
  end

  def show
    check = current_user.checks.find(params[:id])
    render json: check
  end

  def create
    check = current_user.checks.create!(
      check_params.merge(status: 'created')
    )
    render json: check
  end

  def report
    check = current_user.checks.find(params[:check_id])
    return render json: {}, status: 404 unless check.unanonymized_report_exists?

    redirect_to url_for(check.unanonymized_report)
  end

  def start
    check = current_user.checks.find(params[:check_id])

    return render json: {}, status: 400 unless check.can_start?

    check.transition_to_queued
    StartCheckJob.perform_later(check.id)

    render json: {}, status: 202
  end

  def upload_base_submission
    check = current_user.checks.find(params[:check_id])

    return render json: {}, status: 400 unless check.created?

    check.update!(base_submission: params[:base_submission])
  end

  private

  def checks_params
    params.permit(id: [])
  end

  def check_params
    params.require(:check).permit(:name)
  end
end
