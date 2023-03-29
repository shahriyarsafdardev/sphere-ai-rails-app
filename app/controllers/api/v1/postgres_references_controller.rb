# frozen_string_literal: true

class Api::V1::PostgresReferencesController < ApplicationController
  include UserHelper
  before_action :find_user_through_email, only: %i[my_references create]
  before_action :set_postgres_reference, only: %i[query show update]

  def index
    @postgres_references = PostgresReference.all
    render json: @postgres_references, each_serializer: PostgresReferenceSerializer, status: :ok
  end

  def my_references
    @postgres_references = @user.postgres_references
    render json: @postgres_references, each_serializer: PostgresReferenceSerializer, status: :ok
  end

  def create
    @postgres_reference = @user.postgres_references.new(postgres_reference_params)
    render json: @postgres_reference, message: 'Postgres reference created successfully!', status: :ok if @postgres_reference.save!
  end

  def update
    @postgres_reference.update!(postgres_reference_params)

    render json: @postgres_reference, message: 'Postgres reference updated successfully!', status: :ok
  end

  def show
    render json: @postgres_reference, status: :ok
  end

  def query
    begin
      result = @postgres_reference.run_query(params[:query])
      render json: result, status: :ok
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end
  end

  private

  def postgres_reference_params
    params.require(:postgres_reference).permit(:title, :db_name, :db_user_name, :password, :host, :port)
  end

  def set_postgres_reference
    @postgres_reference = PostgresReference.find_by(id: params[:id])
    return if @postgres_reference.present?

    render json: { message: 'Postgres reference not found!' },
           status: :unprocessable_entity
  end
end
