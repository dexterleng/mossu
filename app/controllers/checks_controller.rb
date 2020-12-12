class ChecksController < ApplicationController
  def index
    checks = Check.all.order(:created_at)
    render json: checks
  end

  def show
    check = Check.find(params[:id])
    render json: check
  end

  def create
    check = Check.create!(
      check_params.merge(status: 'created')
    )
    render json: check
  end

  def report
    check = Check.find(params[:check_id])
    return render json: {}, status: 404 unless check.report_exists?

    redirect_to url_for(check.report)
  end

  def start
    check = Check.find(params[:check_id])

    return render json: {}, status: 400 unless check.can_start?

    check.transition_to_queued
    StartCheckJob.perform_later(check.id)

    render json: {}, status: 202
  end

  private

  def check_params
    params.require(:check).permit(:name)
  end
end
