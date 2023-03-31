# frozen_string_literal: true

class User < ApplicationRecord

  extend FriendlyId
  friendly_id :slugged_candidates, use: :slugged

  validates :first_name, :last_name, :slug, :email, presence: true
  validates :email, :slug, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist,
                               omniauth_providers: [:google_oauth2]

  def self.from_omniauth(auth)
    first_name, last_name = auth['name']&.split(' ')
    User.where(email: auth['email']).first_or_create do |user|
      user.email = auth['email']
      user.password = Devise.friendly_token[0, 20]
      user.first_name = first_name
      user.last_name = last_name
      user.profile_picture_data = auth['picture']
    end
  end

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

# rubocop:enable Lint/Syntax
