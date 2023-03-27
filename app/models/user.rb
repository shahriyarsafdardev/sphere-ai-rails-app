# frozen_string_literal: true

class User < ApplicationRecord
  has_many :postgres_references, dependent: :destroy

  extend FriendlyId
  has_many :hubspot_references, dependent: :destroy
  friendly_id :slugged_candidates, use: :slugged

  validates :first_name, :last_name, :slug, :email, presence: true
  validates :email, :slug, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_password_token
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    self.reset_password_token = hashed
    self.reset_password_sent_at = Time.current.utc
    save
    raw
  end

  private

  def slugged_candidates
    %i[full_name slug_if_name_taken]
  end

  def slug_if_name_taken
    slug = "#{first_name}-#{last_name}".downcase
    sequence = User.where('slug LIKE ?', "%#{slug}%").count + 1
    "#{slug}--#{sequence}"
  end

  def should_generate_new_friendly_id?
    first_name_changed? || last_name_changed? || super
  end
end
