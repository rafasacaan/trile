class Circuit < ActiveRecord::Base
  #each circuit has many measures and the existence of measures is dependent on the existence of the circuit
  has_many :measures, dependent: :destroy
  scope :demands, -> { where(type: 'demand') } 
  scope :generations, -> { where(type: 'generation') }
  before_destroy :ensure_not_referenced_by_any_measure
  before_save :default_values
  after_initialize :set_status
  
  attr_accessor :status, :current_user, :part

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

def specific_day_measures(date, variation)
    var = if variation then variation else 3 end
    Circuit.find_by_sql(["SELECT * FROM(                         "+
                         "SELECT                                 "+
                         "measures.watts,                        "+
                         "measures.created_at,                   "+
                         "(case                                  "+ 
                         "WHEN(lag(watts) over () is NULL)       "+
                         "THEN 100                               "+  
                         "ELSE                                   "+
                         "abs(                                   "+
                         "lag(watts)over()::float/watts - 1      "+ 
                         "  )*100                                "+ 
                         "end) as variation_last,                "+
                         "(case when(lead(watts) over () is NULL) THEN 100 ELSE abs(lead(watts)over()::float/watts - 1)*100 end) as  variation_next "+
                         "FROM                                   "+ 
                         "#{Apartment::Tenant.current}.measures  "+
                         "WHERE                                  "+ 
                         "measures.circuit_id = ? AND            "+
                         "measures.created_at >= ? AND           "+
                         "measures.created_at <= ?               "+
                         "ORDER BY                               "+
                         "measures.created_at ASC ) AS stats     "+
                         "WHERE                                  "+
                         "variation_last > #{var} and variation_next > #{var} OR "+
                         "variation_last < #{var} and variation_next > #{var} OR "+
                         "variation_last > #{var} and variation_next < #{var}; ",
                          self.id,date.beginning_of_day,date.end_of_day])
    end

  def today_measures(variation)
    var = if variation then variation else 3 end
    Circuit.find_by_sql(["SELECT * FROM(                        "+
                         "SELECT                                "+
                         "measures.watts,                       "+
                         "measures.created_at,                  "+
                         "(case                                 "+ 
                         "WHEN(lag(watts) over () is NULL)      "+
                         "THEN 100                              "+  
                         "ELSE                                  "+
                         "abs(                                  "+
                         "lag(watts)over()::float/watts - 1     "+ 
                         "  )*100                               "+ 
                         "end) as variation_last,               "+
                         "(case when(lead(watts) over () is NULL) THEN 100 ELSE abs(lead(watts)over()::float/watts - 1)*100 end) as  variation_next "+
                         "FROM                                  "+ 
                         "#{Apartment::Tenant.current}.measures "+
                         "WHERE                                 "+ 
                         "measures.circuit_id = ? AND           "+
                         "measures.created_at >= ? AND          "+
                         "measures.created_at <= ?              "+
                         "ORDER BY                              "+
                         "measures.created_at ASC ) AS stats    "+
                         "WHERE                                 "+
                         "variation_last > #{var} and variation_next > #{var} OR "+
                         "variation_last < #{var} and variation_next > #{var} OR "+
                         "variation_last > #{var} and variation_next < #{var}; ",
                          self.id,
                          Time.now.midnight,
                          Time.now])
    end

  def week_measures(date)
    date = if date then date else Date.yesterday end
    #don't forget to refactor routes and controller it shuold be named hours_day 
    Circuit.find_by_sql(["SELECT trunc(cast(SUM(Watts) AS numeric),2) AS \"watts\", hours      "+
                         "FROM(                                                                "+
                         "SELECT                                                               "+
                         "measures.watts *                                                     "+
                         "EXTRACT(epoch FROM (measures.created_at - lag(measures.created_at)   "+
                         "over (order by measures.created_at)))/3600 AS Watts,                 "+
                         "to_char(measures.created_at,'HH24') AS hours                         "+
                         "FROM                                                                 "+ 
                         "#{Apartment::Tenant.current}.measures                                "+
                         "WHERE                                                                "+ 
                         "measures.circuit_id = ? AND                                          "+
                         "measures.created_at >= ? AND                                         "+
                         "measures.created_at <= ?                                             "+
                         "ORDER BY                                                             "+
                         "hours ASC ) AS stats                                                 "+
                         "GROUP BY 2                                                           ",
                          self.id,
                          date.beginning_of_day,date.end_of_day
                          ])
    #measures.where("created_at >= ?", 1.week.ago.utc).select("created_at, watts").order(:created_at)
  end

  def month_measures
    measures = Circuit.find_by_sql(["SELECT trunc(cast(SUM(Watts) AS numeric),2) AS \"watts\", to_char((created_at),'YYYY-MM-DD') as dt               "+
                         "FROM(                                                                                                                       "+
                         "SELECT                                                                                                                      "+
                         "measures.watts *                                                                                                            "+   
                         "EXTRACT(epoch FROM (#{Apartment::Tenant.current}.measures.created_at - lag(#{Apartment::Tenant.current}.measures.created_at)"+ 
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

  def data_tool_day(date,variation)
    var = if variation then variation else 20 end
    data = Circuit.find_by_sql(["SELECT * FROM(                 "+
                         "SELECT                                "+
                         "circuits.description,                 "+
                         "measures.watts,                       "+
                         "measures.created_at,                  "+
                         "row_number() OVER () as rnum          "+
                         "FROM                                  "+ 
                         "#{Apartment::Tenant.current}.measures,"+
                         "#{Apartment::Tenant.current}.circuits "+
                         "WHERE                                 "+ 
                         "circuits.id = measures.circuit_id     "+
                         "AND                                   "+
                         "measures.created_at >= ?              "+
                         "AND                                   "+
                         "measures.created_at <= ?              "+
                         "ORDER BY                              "+
                         "measures.created_at ASC ) AS stats    "+
                         "WHERE                                 "+
                         "rnum >= ?;                            ",
                         date,date.end_of_day, var])
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
          puts d["watts"]
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

    def self.circuits_watts_sum(date)
    date = if date then date else Date.today.beginning_of_day end
        measures = Circuit.find_by_sql(
            ["SELECT *, "+
            "(Wattshora/sum(Wattshora) over ())*100 as part   "+
            "FROM(                                            "+ 
            "SELECT stats.ids, sum(area) as Wattshora         "+
            " FROM(                                           "+
            "  SELECT *,                                      "+
            "  circuit_id as ids,                             "+
            "  (CASE                                          "+
            "  WHEN(EXTRACT(epoch FROM (                      "+
            "  created_at - lag(created_at) over (            "+
            "  partition by circuit_id order by created_at)   "+
            "  )) > 30) THEN 0                                "+ 
            "  ELSE                                           "+ 
            "  watts * EXTRACT(epoch FROM (                   "+
            "  created_at - lag(created_at) over (            "+
            "  partition by circuit_id order by created_at))) "+
            "  /3600  END) AS area                            "+
            "  FROM                                           "+
            "   prv_7.measures                                "+  
            "   WHERE                                         "+
            "   created_at >= ?                               "+
            "   ORDER BY created_at ASC) AS stats             "+ 
            "   group by 1) as prev                           ",
            date])
        
        measures.each do |m|
            m.class.module_eval { attr_accessor :description}
            m.description = Circuit.select("description").find(m.ids)['description']
            puts m.description      
        end
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
