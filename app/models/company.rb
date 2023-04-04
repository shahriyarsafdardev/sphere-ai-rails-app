# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :documents, dependent: :destroy
end
