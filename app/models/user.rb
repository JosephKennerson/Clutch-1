class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
         # , :omniauth_providers => [:facebook]
  has_many :rsvps, foreign_key: :guest_id
  has_many :events, foreign_key: :host_id
  has_many :events_requested_to, through: :rsvps, source: :event
  has_many :comments
  has_many :ratings
  has_many :given_ratings, class_name: "Rating", foreign_key: "rater_id"
  has_many :received_ratings, class_name: "Rating", foreign_key: "ratee_id"

  # validates_uniqueness_of :phone_number
  # validates :phone_number, phone: { possible: false, allow_blank: true, types: [:mobile] }

  # def given_reviews
  #   self.ratings.where(rater: self.id)
  # end

  # def received_feedback
  #   self.ratings.where(ratee: self.id)
  # end

  # geocoded_by :ip_address

  geocoded_by :full_address

  # the callback to set longitude and latitude
  after_validation :geocode, if: :full_address_changed?

  # the full_address method
  def full_address
   "#{address_line_1}, #{address_line_2}, #{city}, #{state}, #{zip}"
  end

  def full_address_changed?
    :address_line_1_changed? || :address_line_2_changed? || :city_changed? || :state_changed? || :zip_changed?
  end

  # get full name
  def full_name
    "#{first_name} #{last_name}"
  end

# ***** Original Facebook Login Auth ******
  # def self.from_omniauth(auth)
  #     where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  #       user.provider = auth.provider
  #       user.uid = auth.uid
  #       user.email = auth.info.email
  #       user.password = Devise.friendly_token[0,20]
  #     end
  # end

# ***** Facebook Login Auth ******
  def self.from_omniauth(auth)
  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    user.email = auth.info.email || "#{auth.info.nickname}@facebook.com"
    user.password = Devise.friendly_token[0,20]
    user.username = auth.info.name   # assuming the user model has a name
  end
end

  def confirmed_events(userid)
    attending_events = []
    Rsvp.where(guest_id: userid, confirmed: true).each do |rsvp|
      attending_events << Event.find(rsvp.event_id)
    end
    return attending_events
  end

end
