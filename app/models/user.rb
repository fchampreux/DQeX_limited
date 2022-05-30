# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  playground_id          :bigint
#  organisation_id        :bigint
#  current_playground_id  :integer          default(1)
#  external_directory_id  :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  name                   :string(255)
#  user_name              :string(255)      not null
#  language               :string(255)      default("en")
#  description            :text
#  active_from            :datetime
#  active_to              :datetime
#  is_admin               :boolean          default(FALSE)
#  is_active              :boolean          default(TRUE)
#  owner_id               :integer
#  created_by             :string(255)      not null
#  updated_by             :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#

class User < ApplicationRecord
  extend CsvHelper

  # Audit trail setup
  audited except: [:encrypted_password,  :reset_password_token,  :reset_password_sent_at,  :remember_created_at,
                    :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip,
                    :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email,
                    :failed_attempts, :unlock_token, :locked_at]

  #validates_with EmailAddress::ActiveRecordValidator, field: :email

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
            :trackable, :confirmable, :lockable, :password_archivable, :registerable,
            :omniauthable, omniauth_providers: %i[keycloakopenid]#, :secure_validatable

  before_save :email_format
  before_save :name_update

### validations
  # validates :current_playground_id, presence: true
  validates :email, :presence => true, uniqueness: {case_sensitive: false}, length: { maximum: 100 }
  #validates_format_of :email, with: /\A(\S+)@(.+)\.(\S+)\z/
  validate :password_confirmed
  validate :password_complexity

  validates :first_name,    presence: true, length: { maximum: 100 }
  validates :last_name,     presence: true, length: { maximum: 100 }
  validates :user_name,     presence: true, uniqueness: {case_sensitive: false}, length: { maximum: 100 }
  #validates :external_directory_id,         length: { maximum: 100 }
  validates :created_by,    presence: true, length: { maximum: 30 }
  validates :updated_by,    presence: true, length: { maximum: 30 }
  #validate :member_of_Everyone_group
  belongs_to :organisation, optional: true
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"

# Relations
  has_and_belongs_to_many :groups
  has_many :groups_users

  ### Translation support
  mattr_accessor :translated_fields, default: ['description']
	has_many :translations, as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true

### Public functions
  def activity_status
    if self.is_active
      if not self.locked_at.nil?
        "locked"
      else
        if self.confirmed_at.nil?
          "Unconfirmed"
        else
          if self.sign_in_count == 0
            "Confirmed"
          else
            "Active"
          end
        end
      end
    else
      "Inactive"
    end
  end

  def principal_group
    self.groups_users.find_by(is_principal: true).group_id
  end

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/

    errors.add :password, 'Complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
  end

  def password_confirmed
    return if password == password_confirmation

    errors.add :password, 'Password and confirmation do not match'
  end

  ### full-text local search
  pg_search_scope :search_by_user_name, against: [:user_name, :name, :description],
    using: { tsearch: { prefix: true, negation: true } }

  def self.search(criteria)
    if criteria.present?
      search_by_user_name(criteria)
    else
      # No query? Return all records, sorted by hierarchy.
      order( :updated_at )
    end
  end

  # Allow user creation when a new one comes through OmniAuth
  def self.from_omniauth(auth)
    where(provider: auth.provider, email: auth.info.email).first_or_create do |user|
      user.login = auth.info.email
      user.uuid = auth.uid
      user.provider = auth.provider
      user.email = auth.info.email
      user.password = "Odq!1#{Devise.friendly_token[0, 20]}"
      user.password_confirmation = user.password
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.name = auth.info.name   # assuming the user model has a name
      user.user_name = auth.info.email[0, 32]
      # user.playground_id = 0
      user.current_playground_id = 0
      user.organisation_id = Parameter.find_by_code("ORGANISATION_ID").property.to_i || 0
      user.language = 'fr_OFS'
      user.description = 'Created through OmniAuth'
      user.active_from = Time.now
      user.active_to = Time.now + 3.years
      user.is_admin = false
      user.is_active = true
      user.owner_id = 1
      user.created_by = 'OmniAuth'
      user.created_at = Time.now
      user.updated_by = 'OmniAuth'
      user.updated_at = Time.now
      user.confirmed_at = Time.now
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      user.skip_confirmation!
    end
  end

### private functions definitions
  private

  ### before filters

  def email_format
    self.email = email.downcase
  end

  def name_update
    self.name = "#{first_name} #{last_name}"
   end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(user_name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:user_name) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def member_of_Everyone_group
    errors.add(:base, :EveryoneMembershipMissing) unless group_ids.include? 0
  end

end
