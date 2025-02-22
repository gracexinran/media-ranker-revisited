class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :name, uniqueness: true, presence: true
  validates :uid, uniqueness: true, presence: true 
  validates :email, uniqueness: true, presence: true, format: { with: /@/, message: "format must be valid." }
  
  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash[:uid]
    user.provider = "github"
    user.name = auth_hash["info"]["nickname"]
    user.email = auth_hash["info"]["email"]
    return user
  end
end
