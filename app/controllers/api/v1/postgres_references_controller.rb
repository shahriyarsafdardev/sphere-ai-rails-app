# frozen_string_literal: true

class Api::V1::PostgresReferencesController < ApplicationController
  include UserHelper
  before_action :find_user_through_email, only: %i[my_references create]
  before_action :set_postgres_reference, only: %i[query show update]

  def index
    @postgres_references = PostgresReference.all
    render json: { references: @postgres_references }, status: :ok
  end

  def my_references
    @postgres_references = @user.postgres_references
    render json: { references: @postgres_references }, status: :ok
  end

  def create
    @postgres_reference = @user.postgres_references.new(postgres_reference_params)
    render json: { reference: @postgres_reference }, status: :ok if @postgres_reference.save!
  end

  def update
    @postgres_reference.update!(postgres_reference_params)

    render json: { reference: @postgres_reference }, status: :ok
  end

  def show
    render json: { reference: @postgres_reference }, status: :ok
  end

  def query
    result = GptService.query_with_postgres_reference(@postgres_reference, params[:query])
    parsed_query = result.split('::')&.second&.split('::')&.first
    query_response = PostgresService.execute_query(@postgres_reference, parsed_query)
    render json: { message: result, query: parsed_query, result: query_response }, status: :ok
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
