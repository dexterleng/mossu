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

  private

  def check_params
    params.require(:check).permit(:name)
  end
end
