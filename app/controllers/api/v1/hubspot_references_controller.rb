require 'hubspot-api-client'

class Api::V1::HubspotReferencesController < ApplicationController
  before_action :set_hubspot_reference, only: %i[show update destroy]

  def index
    @hubspot_references = HubspotReference.all

    render json: @hubspot_references
  end

  def show
    render json: @hubspot_reference
  end

  def create
    @hubspot_reference = HubspotReference.new(hubspot_reference_params)

    render json: @hubspot_reference, status: :ok if @hubspot_reference.save!
  end

  def update
    if @hubspot_reference.update(hubspot_reference_params)
      render json: @hubspot_reference
    else
      render json: @hubspot_reference.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @hubspot_reference.destroy
  end

  def all_hubspot_contacts
    # client = Hubspot::Client.new(access_token: '')
    # client.crm.contacts.basic_api.get_all
  end

  private

  def set_hubspot_reference
    @hubspot_reference = HubspotReference.find(params[:id])
  end

  def hubspot_reference_params
    params.require(:hubspot_reference).permit(:name, :hubspot_access_token, :environment)
  end
end
