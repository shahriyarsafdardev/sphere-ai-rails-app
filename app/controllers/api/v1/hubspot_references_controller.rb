# frozen_string_literal: true

require 'hubspot-api-client'
class Api::V1::HubspotReferencesController < ApplicationController
  before_action :set_hubspot_reference, only: %i[show update destroy query]
  before_action :authenticate_user!

  def index
    @hubspot_references = HubspotReference.all

    render json: @hubspot_references, each_serializer: HubspotReferenceSerializer, status: :ok
  end

  def show
    render json: @hubspot_reference, serializer: HubspotReferenceSerializer, status: :ok
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

  def query
    begin 
      response = @hubspot_reference.run_query(params[:query])
      render json: { result: response[:result].results.map{ |res| res.properties } }, status: :ok
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end
  end

  def my_references
    @hubspot_references = current_user.hubspot_references
    render json: @hubspot_references, each_serializer: HubspotReferenceSerializer, status: :ok
  end

  private

  def set_hubspot_reference
    @hubspot_reference = HubspotReference.find(params[:id])
  end

  def hubspot_reference_params
    params.require(:hubspot_reference).permit(:name, :hubspot_access_token, :environment)
  end
end
