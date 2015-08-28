class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessor :login
  delegate :demands, :generations, to: :circuits  
  before_create :set_auth_token
  validates :email, :uniqueness => { :case_sensitive => false }
  after_create :after_save

 
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
     if login = conditions.delete(:login)
        where(conditions.to_hash).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
     else
        where(conditions.to_hash).first
     end
  end
  

private

    def set_auth_token
        return if auth_token.present?
        self.auth_token = generate_auth_token
    end

    def generate_auth_token
      loop do
          token = SecureRandom.hex
        break token unless self.class.exists?(auth_token: token)
      end
    end

    def after_save
      if schema_name.nil?
      update_attribute :schema_name, "prv_#{id}" 
      Apartment::Tenant.create(schema_name)
    end
   end

end
