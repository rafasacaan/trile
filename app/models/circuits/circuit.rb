class Circuit < ActiveRecord::Base
  #each circuit has many measures and the existence of measures is dependent on the existence of the circuit
  has_many :measures, dependent: :destroy
  scope :demands, -> { where(type: 'demand') } 
  scope :generations, -> { where(type: 'generation') }
  before_destroy :ensure_not_referenced_by_any_measure
  before_save :default_values
  after_initialize :set_status
  
  attr_accessor :status, :current_user

 def self.types
      %w(Demand Generation)
 end
 
 def last_measure
    measures.last 
 end

 def set_status
  if self.measures.count == 0
          self.status = "No measures"
      else
        if (Time.now-self.measures.order(:created_at).last.created_at) > self.alarm_time*60
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
                         "#{Apartment::Tenant.current}.measures       "+
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
                         "#{Apartment::Tenant.current}.measures       "+
                         "WHERE                              "+ 
                         "measures.circuit_id = ? AND        "+
                         "measures.created_at >= ? AND       "+
                         "measures.created_at <= ?           "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,6) = 0;                   ",
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
                         "#{Apartment::Tenant.current}.measures       "+
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
    measures = Circuit.find_by_sql(["SELECT trunc(cast(SUM(Watts) AS numeric),2) AS \"watts\", to_char((created_at),'YYYY-MM-DD') as dt               "+
                         "FROM(                                                                                                                       "+
                         "SELECT                                                                                                                      "+
                         "measures.watts *                                                                                                            "+   
                         "EXTRACT(epoch FROM (#{Apartment::Tenant.current}.measures.created_at - lag(#{Apartment::Tenant.current}.measures.created_at)                  "+ 
                         "over (order by measures.created_at)))/3600 AS Watts,                 "+
                         "measures.created_at                                                  "+
                         "FROM                                                                 "+ 
                         "public.circuits,                                                     "+
                         "#{Apartment::Tenant.current}.measures                                "+
                         "WHERE                                                                "+ 
                         "circuits.id = ? AND                                                  "+
                         "measures.circuit_id = ? AND                                          "+
                         "measures.created_at >= ? ) AS stats                                  "+
                         "GROUP BY 2                                                           "+
                         "ORDER BY dt ASC;                                                     ",
                          self.id,
                          self.id,
                          Time.now.at_beginning_of_month])
 	
    data = []
    days_in_month = (Date.today.at_beginning_of_month..Date.today.at_end_of_month).map {|day| data << {"dt" => day.to_time.to_i, "watts" => 0}}
     
    data.each do |d|
      measures.each do |m|
        if d["dt"] == m.dt.to_time.to_i
        d["watts"] = m.watts
        end
      end
    end
  
  end
 
  def year_measures
    Circuit.find_by_sql(["SELECT dt, trunc(cast(\"Wattshora\" AS numeric),2) AS \"watts\"                                                                                                                                      "+
                         "FROM ( SELECT to_char(dt,'TMmon') as dt                                                                                                                                                              "+
                         "FROM generate_series('2015-01-01 00:00'::timestamp, '2015-12-31 00:00'::timestamp, '1 month'::interval) dt) AS t1                                                                                    "+
                         "LEFT OUTER JOIN (SELECT SUM (stats.Watts) AS \"Wattshora\", stats.mon                                                                                                                                "+
                         "FROM ( SELECT                                                                                                                                                                                        "+                             
                         "#{Apartment::Tenant.current}.measures.watts * EXTRACT(epoch FROM (#{Apartment::Tenant.current}.measures.created_at - lag(#{Apartment::Tenant.current}.measures.created_at) over (order by measures.created_at)))/3600 AS Watts, "+                   
                         "to_char(measures.created_at,'TMmon') AS mon,                                                                                                                                                         "+               
                         "row_number() OVER () as rnum                                                                                                                                                                         "+       
                         "FROM                                                                                                                                                                                                 "+
                         "public.circuits,                                                                                                                                                                                     "+                               
                         "#{Apartment::Tenant.current}.measures                                                                                                                                                                         "+                   
                         "WHERE                                                                                                                                                                                                "+
                         "circuits.id = ? AND                                                                                                                                                                                  "+                               
                         "measures.circuit_id = ? AND                                                                                                                                                                          "+        
                         "measures.created_at >= ?) AS stats                                                                                                                                                                   "+
                         "WHERE                                                                                                                                                                                                "+
                         "mod(rnum,30) = 0                                                                                                                                                                                     "+
                         "GROUP BY 2) AS t2                                                                                                                                                                                    "+
                         "ON (t1.dt = t2.mon);",
                          self.id,
                          self.id,
                          Time.now.at_beginning_of_year ])  
  end

  def data_tool_week(date)
    data = Circuit.find_by_sql(["SELECT * FROM(              "+
                         "SELECT                             "+
                         "circuits.description,              "+
                         "measures.watts,                    "+
                         "measures.created_at,               "+
                         "row_number() OVER () as rnum       "+
                         "FROM                               "+ 
                         "#{Apartment::Tenant.current}.measures,"+
                         "#{Apartment::Tenant.current}.circuits "+
                         "WHERE                              "+ 
                         "circuits.id = measures.circuit_id  "+
                         "AND                                "+
                         "measures.created_at >= ?           "+
                         "AND                                "+
                         "measures.created_at <= ?           "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,5) = 0;                   ",
                         date.beginning_of_week,date.end_of_week])
        
        format(data) 
  end

  def data_tool_day(date)
    data = Circuit.find_by_sql(["SELECT * FROM(              "+
                         "SELECT                             "+
                         "circuits.description,              "+
                         "measures.watts,                    "+
                         "measures.created_at,               "+
                         "row_number() OVER () as rnum       "+
                         "FROM                               "+ 
                         "#{Apartment::Tenant.current}.measures,"+
                         "#{Apartment::Tenant.current}.circuits "+
                         "WHERE                              "+ 
                         "circuits.id = measures.circuit_id  "+
                         "AND                                "+
                         "measures.created_at >= ?           "+
                         "AND                                "+
                         "measures.created_at <= ?           "+
                         "ORDER BY                           "+
                         "measures.created_at ASC ) AS stats "+
                         "WHERE                              "+
                         "mod(rnum,5) = 0;                   ",
                         date,date.end_of_day])
        
                        format(data) 
    end

    def self.data_tool_month(date)
    measures = Circuit.find_by_sql(["SELECT trunc(cast(SUM(Watts) AS numeric),2) AS \"watts\", to_char(created_at,'YYYY-MM-DD')::timestamp as dt, circuit "+
                         "FROM(                                                                                                                        "+
                         "SELECT                                                                                                                       "+
                         "#{Apartment::Tenant.current}.circuits.description AS circuit,                                                                "+
                         "#{Apartment::Tenant.current}.measures.watts *                                                                                "+   
                         "EXTRACT(epoch FROM (#{Apartment::Tenant.current}.measures.created_at - lag(#{Apartment::Tenant.current}.measures.created_at) "+ 
                         "over (order by #{Apartment::Tenant.current}.measures.created_at)))/3600 AS Watts,                                            "+
                         "#{Apartment::Tenant.current}.measures.created_at                                                                             "+
                         "FROM                                                                                                                         "+ 
                         "#{Apartment::Tenant.current}.circuits,                                                                                       "+
                         "#{Apartment::Tenant.current}.measures                                                                                        "+
                         "WHERE                                                                                                                        "+ 
                         "measures.created_at >= ? ) AS stats                                                                                          "+
                         "GROUP BY 2,3                                                                                                                 "+
                         "ORDER BY dt ASC;                                                                                                             ",
                          date.at_beginning_of_month])
  
    circuits = Circuit.select('description')
    data = []
    days_in_month = (date.at_beginning_of_month..date.at_end_of_month)
    
    days_in_month.each do |day|
      circuits.each do |c|
        #revisar y reparar esta parte de los time zone. Todo tiene que quedar sincronizado. Rails, el server y la bdd
        data << {"dt" => day.to_time.to_i - 3.hours, "watts" => 0, "circuit" => c.description}
      end
    end

     data.each do |d|
       measures.each do |m|
         if d["dt"] == m.dt.to_time.to_i && d["circuit"] == m.circuit
         d["watts"] = m.watts
         else 
         d["watts"] = 0  
         end         
       end
     end

    a = []
      data.each do |d|
        hash = {d["circuit"] => d["watts"], :dt => d["dt"]}
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

  def format(data)
  #Data formating
        a = []   
        data.each do |d|
          hash = {d.description.parameterize.underscore.titleize.to_sym => d.watts, :created_at => d.created_at}
          a.push(hash)
        end
        return a
  end

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
