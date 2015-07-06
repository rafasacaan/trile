class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessor :login
  has_many :circuits
  delegate :demands, :generations, to: :circuits  
  before_create :set_auth_token


  
  def energy_sum_current_month(id = self.id)
  energy = User.find_by_sql(["SELECT SUM(Watts) AS \"Wattshora\", to_char(created_at,'Mon') as mon, extract(year from created_at) as year,\"type\""+     
                            "FROM(                                                                "+
                            "SELECT                                                               "+
                            "circuits.type as \"type\",                                           "+
                            "measures.created_at,                                                 "+
                            "measures.watts *                                                     "+ 
                            "EXTRACT(epoch FROM (measures.created_at - lag(measures.created_at)   "+
                            "over (order by measures.created_at)))/3600 AS Watts                  "+   
                            "FROM                                                                 "+
                            "public.users,                                                        "+
                            "public.circuits,                                                     "+
                            "public.measures                                                      "+
                            "WHERE                                                                "+ 
                            "users.id = ? AND                                                     "+ 
                            "measures.created_at >= ?) AS foo                                     "+
                            "GROUP BY 2,3,4;",id, Time.now.at_beginning_of_month])
  end
  
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

end
