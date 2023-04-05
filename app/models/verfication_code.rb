# frozen_string_literal: true

class VerificationCode < ApplicationRecord
  belongs_to :users
end