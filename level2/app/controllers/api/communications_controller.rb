class Api::CommunicationsController < ApplicationController

  def create
    practitioner = Practitioner.where(first_name: communication_params[:first_name], last_name: communication_params[:last_name]).first

    communication = Communication.new(practitioner: practitioner, sent_at: communication_params[:sent_at])

    communication.save

    render json: communication.to_json, status: :created
  end

  def index
    render json: Communication.includes(:practitioner).all.to_json, status: :ok
  end

  def communication_params
    params.require(:communication).permit(:first_name, :last_name, :sent_at)
  end

end
