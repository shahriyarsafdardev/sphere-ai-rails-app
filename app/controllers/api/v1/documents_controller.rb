# frozen_string_literal: true

class Api::V1::DocumentsController < ApplicationController
  before_action :authenticate_user!

  def search
    @query = params[:query]
    offset = params[:offset].to_i
    total_documents = Document.all.length
    @result = Document.includes(:company).limit(25).offset(offset)&.map do |document|
      matches = get_matches(document)&.compact
      document_object(document)&.merge({ matches: matches }) if matches.present?
    end
    render json: { result: @result&.compact, offset: offset + 25, total_documents: total_documents }, status: :ok
  end

  private

  def get_matches(document)
    regex = /#{@query}/i

    document&.transcript&.map do |page|
      page_matches = []
      text = page['text']
      words = text.scan(/[\w']+|\p{P}/)
      words.each_with_index do |_word, i|
        next unless regex.match?(words[i...(i + @query.split(' ').length)].join(' '))

        start_index = [0, i - 50].max
        end_index = [words.length - 1, i + @query.split(' ').length + 50].min
        context_words = words[start_index..end_index]
        context = context_words.join(' ').strip
        page_matches << context
      end
      { page_number: page['number'], page_matches: page_matches } if page_matches.present?
    end
  end

  def document_object(document)
    { id: document&.id,
      title: document&.title,
      url: document&.url,
      published_at: document&.published_at,
      company_name: document&.company&.name, }
  end
end
