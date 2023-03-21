class User < ApplicationRecord
  extend FriendlyId
  friendly_id :slugged_candidates, use: :slugged

  validates :first_name, :last_name, :slug, :email, presence: true

  validates :email, :slug, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def full_name
    "#{first_name} #{last_name}"
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
