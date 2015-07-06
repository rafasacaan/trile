class Circuit < ActiveRecord::Base
  #each circuit belongs only to a specific user account
  belongs_to :user
  #each circuit has many measures and the existence of measures is dependent on the existence of the circuit
  has_many :measures, dependent: :destroy
  scope :demands, -> { where(type: 'demand') } 
  scope :generations, -> { where(type: 'generation') }
  before_destroy :ensure_not_referenced_by_any_measure
  before_save :default_values
  after_initialize :set_status
  
  attr_accessor :status

 def self.types
      %w(Demand Generation)
 end
 
 def last_measure
    self.measures.last 
 end

 def set_status
  if self.measures.count == 0
          self.status = "No measures"
      else
        if (Time.now-self.measures.last.created_at) > self.alarm_time*60
          self.status = "Problem"
        else
          self.status = "Ok" 
        end
      end 
 end

def specific_day_measures(date)
    Circuit.find_by_sql(["SELECT * FROM(                     "+
                         "SELECT                             "+
                         "measures.watts,                    "+
                         "measures.created_at,               "+
                         "row_number() OVER () as rnum       "+
                         "FROM                               "+ 
                         "public.measures                    "+
                         "WHERE                              "+ 
                         "measures.circuit_id = ? AND        "+
                         "measures.created_at >= ? AND       "+
                         "measures.created_at <= ?           "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,3) = 0;                   ",
                          self.id,
                          date.beginning_of_day,
                          date.end_of_day])
    #This method retrieves every measure and it to slow for production. The above is 3 times faster!
    #measures.where(:created_at => date.beginning_of_day..date.end_of_day).select("created_at, watts").order(:created_at)
  end

  def today_measures
    Circuit.find_by_sql(["SELECT * FROM(                     "+
                         "SELECT                             "+
                         "measures.watts,                    "+
                         "measures.created_at,               "+
                         "row_number() OVER () as rnum       "+
                         "FROM                               "+ 
                         "public.measures                    "+
                         "WHERE                              "+ 
                         "measures.circuit_id = ? AND        "+
                         "measures.created_at >= ? AND       "+
                         "measures.created_at <= ?           "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,3) = 0;                   ",
                          self.id,
                          Time.now.midnight,
                          Time.now])
    #This method retrieves every measure and it to slow for production. The above is 3 times faster!
 	  #measures.where(created_at: Time.now.midnight..Time.now).select("created_at, watts").order(:created_at)
  end

  def week_measures
    Circuit.find_by_sql(["SELECT * FROM(                     "+
                         "SELECT                             "+
                         "measures.watts,                    "+
                         "measures.created_at,               "+
                         "row_number() OVER () as rnum       "+
                         "FROM                               "+ 
                         "public.measures                    "+
                         "WHERE                              "+ 
                         "measures.circuit_id = ? AND        "+
                         "measures.created_at >= ?           "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,15) = 0;                   ",
                          self.id,
                          1.week.ago
                          ])
   #measures.where("created_at >= ?", 1.week.ago.utc).select("created_at, watts").order(:created_at)
  end

  def month_measures
    Circuit.find_by_sql(["SELECT * FROM(                     "+
                         "SELECT                             "+
                         "measures.watts,                    "+
                         "measures.created_at,               "+
                         "row_number() OVER () as rnum       "+
                         "FROM                               "+ 
                         "public.measures                    "+
                         "WHERE                              "+ 
                         "measures.circuit_id = ? AND        "+
                         "measures.created_at >= ?           "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,30) = 0;                   ",
                          self.id,
                          1.month.ago
                          ])
 	#self.measures.where("created_at >= ?", 1.month.ago.utc).select("created_at, watts").order(:created_at)
  end
 
  def year_measures
    Circuit.find_by_sql(["SELECT * FROM(                     "+
                         "SELECT                             "+
                         "measures.watts,                    "+
                         "measures.created_at,               "+
                         "row_number() OVER () as rnum       "+
                         "FROM                               "+ 
                         "public.measures                    "+
                         "WHERE                              "+ 
                         "measures.circuit_id = ? AND        "+
                         "measures.created_at >= ?           "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,50) = 0;                   ",
                          self.id,
                          1.year.ago
                          ])
  end

  def index_measures
    data = Circuit.find_by_sql(["SELECT * FROM(              "+
                         "SELECT                             "+
                         "circuits.description,              "+
                         "measures.watts,                    "+
                         "measures.created_at,               "+
                         "row_number() OVER () as rnum       "+
                         "FROM                               "+ 
                         "public.measures,                   "+
                         "public.circuits                    "+
                         "WHERE                              "+ 
                         "circuits.id = measures.circuit_id  "+
                         "AND                                "+
                         "measures.created_at >= ?           "+
                         "AND                                "+
                         "measures.created_at <= ?           "+
                         "AND                                "+
                         "circuits.user_id = ?               "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,5) = 0;                   ",Time.now.midnight,Time.now,self.user_id])
        #Data formating
        a = []   
        data.each do |d|
          hash = {d.description.parameterize.underscore.to_sym => d.watts, :created_at => d.created_at}
          a.push(hash)
        end
        return a
    end
  
    def last_five_measures
      #retrieve the last five measures as object
       data = self.measures.select("watts").order(:created_at).last(10).to_a
       #two empty arrays one for the circuit id an another for the data itself
       arr = []
       a = []
       arr.push(self.id)
       data.each do |d|
        a.push(d.watts)
       end
       arr.push(a)
    end
    
 private

	def ensure_not_referenced_by_any_measure
		if measures.empty?
			return true
		else
			errors.add(:base, 'El circuito tiene mediciones, no se puede borrar')
			return false
		end
	end

	def default_values
    self.alarm_time ||= 5
    self.type ||= "Demand"
  end
  
end
