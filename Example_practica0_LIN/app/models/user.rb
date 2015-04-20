class User
  include Mongoid::Document
  field :name, type: String
  field :email, type: String
  field :age, type: Integer
  field :gender, type: String
  validates_presence_of :name, :email

  before_save :downcase

  has_and_belongs_to_many :movies

  scope :users_by_name, -> { order(name: :asc) }

#Capitalize the users names
#This way is incorect, because iterates over all the users
#It's better doing the capitalization when a user is created or shown
  def self.capitalize_all  
    User.each do |u|
      u.name = u.name.downcase
      u.save
    end
  end

#This way is better, with the callback before_save
  def capitalize
      self.name.capitalize!
  end

#Normalize the value of a string
  def downcase
	  self.name.downcase!
	  self.email.downcase!
  end

end



