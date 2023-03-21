class Api::V1::PostgresReferencesController < ApplicationController
  include PostgresHelper

  before_action :set_user, only: %i[my_references create]
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
    result = execute_query(@postgres_reference, params[:query])
    render json: { result: result }, status: :ok
  end

  private

  def postgres_reference_params
    params.require(:postgres_reference).permit(:db_name, :user_name, :password, :host, :port)
  end

  def set_user
    @user = User.find_by(email: params[:email])
    render json: { message: 'User not found!' }, status: unprocessable_entity if @user.blank?
  end

  def set_postgres_reference
    @postgres_reference = PostgresReference.find_by(id: params[:id])
    return unless @postgres_reference.blank?

    render json: { message: 'Postgres reference not found!' },
           status: unprocessable_entity
  end
end
