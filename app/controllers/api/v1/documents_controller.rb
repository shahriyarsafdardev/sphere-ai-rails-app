# frozen_string_literal: true

class Api::V1::DocumentsController < ApplicationController
  before_action :authenticate_user!

  def search
    @query = params[:query]
    offset = params[:offset].to_i
    total_documents = Document.all.length
    @result = Document.limit(25).offset(offset)&.map do |document|
      matches = get_matches(document)&.compact
      document_object(document)&.merge({ matches: matches }) if matches.present?
    end
    render json: { result: @result&.compact, offset: offset + 25, total_documents: total_documents }, status: :ok
  end

  private

  def get_matches(document)
    regex = /^[\s\S]{0,200}#{@query}[\s\S]{0,200}$/i
    document&.transcript&.map do |page|
      page_matches = page['text']&.scan(regex)
      { page_number: page['number'], page_matches: page_matches } if page_matches.present?
    end
  end

  def document_object(document)
    { id: document&.id,
      title: document&.title,
      url: document&.url,
      published_at: document&.published_at,
      company_name: document&.company&.name,
    }
  end
end
