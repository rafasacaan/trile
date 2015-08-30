class Circuit < ActiveRecord::Base
  #each circuit has many measures and the existence of measures is dependent on the existence of the circuit
  has_many :measures, dependent: :destroy
  scope :demands, -> { where(type: 'demand') } 
  scope :generations, -> { where(type: 'generation') }
  before_destroy :ensure_not_referenced_by_any_measure
  before_save :default_values
    
  attr_accessor :status, :current_user, :part

 def self.types
      %w(Demand Generation)
 end
 
 def last_measure
    measures.last 
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
    date = if date then date else Date.today end
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
                          date.beginning_of_day, date.end_of_day])
  end

  def month_measures(date)
    date = if date then date else Date.today end
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
                         "measures.created_at <= ? AND                                         "+
                         "measures.created_at >= ? ) AS stats                                  "+
                         "GROUP BY 2                                                           "+
                         "ORDER BY dt ASC;                                                     ",
                          self.id,
                          self.id,
                          date.end_of_month,
                          date.at_beginning_of_month
                          ])
 	
    data = []
    days_in_month = (date.at_beginning_of_month..date.at_end_of_month).map {|day| data << {"dt" => day.to_time.to_i, "watts" => 0}}
     
    data.each do |d|
      measures.each do |m|
        if d["dt"] == m.dt.to_time.to_i
        d["watts"] = m.watts
        end
      end
    end
  
  end
 
  def year_measures(date)
    if date then date else Date.today end
    Circuit.find_by_sql(["SELECT dt, trunc(cast(\"Wattshora\" AS numeric),2) AS \"watts\"                                                                                                                                      "+
                         "FROM ( SELECT to_char(dt,'TMmon') as dt                                                                                                                                                              "+
                         "FROM generate_series('2015-01-01 00:00'::timestamp, '2015-12-31 00:00'::timestamp, '1 month'::interval) dt) AS t1                                                                                    "+
                         "LEFT OUTER JOIN (SELECT SUM (stats.Watts) AS \"Wattshora\", stats.mon                                                                                                                                "+
                         "FROM ( SELECT                                                                                                                                                                                        "+                             
                         "measures.watts * EXTRACT(epoch FROM (measures.created_at - lag(measures.created_at) over (order by measures.created_at)))/3600 AS Watts, "+                   
                         "to_char(measures.created_at,'TMmon') AS mon,                                                                                                                                                         "+               
                         "row_number() OVER () as rnum                                                                                                                                                                         "+       
                         "FROM                                                                                                                                                                                                 "+
                         "circuits,                                                                                                                                                                                     "+                               
                         "measures                                                                                                                                                                         "+                   
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
                          date.at_beginning_of_year ])  
  end


def self.watts_sum(date, type)
    date = if date then date else Date.today end

    case type
      when "day"
        start = date.beginning_of_day
        ending = date.end_of_day
      when "week"
        start = date.beginning_of_week
        ending = date.end_of_week
      when "month"
        start = date.beginning_of_month
        ending = date.end_of_month
      when "year"
        start = date.beginning_of_year
        ending = date.end_of_year
      else
        start = date.beginning_of_day
        ending = date.end_of_day
      end
      
        measures = Circuit.find_by_sql(
            ["SELECT *,                                                              "+
            "(Wattshora/sum(Wattshora) over ())*100 as \"part\", ids                 "+
            "FROM(                                                                   "+ 
            "SELECT stats.descr, ids,sum(area) as Wattshora                          "+
            " FROM(                                                                  "+
            "  SELECT *,                                                             "+
            "  description as descr,                                                 "+
            "  circuit_id as ids,                                                    "+
            "  (CASE                                                                 "+
            "  WHEN(EXTRACT(epoch FROM (                                             "+
            "  measures.created_at - lag(measures.created_at) over (                 "+
            "  partition by circuit_id order by measures.created_at)                 "+
            "  )) > 30) THEN 0                                                       "+ 
            "  ELSE                                                                  "+ 
            "  watts * EXTRACT(epoch FROM (                                          "+
            "  measures.created_at - lag(measures.created_at) over (                 "+
            "  partition by circuit_id order by measures.created_at)))               "+
            "  /3600  END) AS area                                                   "+
            "  FROM                                                                  "+
            "   measures inner join circuits on (measures.circuit_id = circuits.id)  "+  
            "   WHERE                                                                "+
            "   measures.created_at >= ?  AND                                        "+
            "   measures.created_at <= ?                                             "+
            "   ORDER BY measures.created_at ASC) AS stats                           "+ 
            "   group by 1,2) as prev                                                "+
            "   order by part desc                                                   ",
            start, ending]) 
       
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
 

def self.peaks(date,type)
    date = if date then date else Date.today end

    case type
      when "day"
        start = date.beginning_of_day
        ending = date.end_of_day
      when "week"
        start = date.beginning_of_week
        ending = date.end_of_week
      when "month"
        start = date.beginning_of_month
        ending = date.end_of_month
      when "year"
        start = date.beginning_of_year
        ending = date.end_of_year
      else
        start = date.beginning_of_day
        ending = date.end_of_day
      end

    Circuit.find_by_sql(["SELECT max(watts), description, id as ids
                            FROM(
                             SELECT
                             measures.watts,
                             circuits.description,
                             circuits.id
                             FROM
                             measures,
                             circuits 
                             WHERE
                             measures.circuit_id = circuits.id AND 
                             measures.created_at >= ? AND
                             measures.created_at <= ?) as stats
                             GROUP BY 2,3;",start, ending])
  end

  def self.sum_energy_week(date)
  date = if date then date else Date.today end
    measures = Circuit.find_by_sql(["SELECT trunc(cast(SUM(Wh) AS numeric),2) AS Wh, time_unit, id "+
                         "FROM(                                                                "+
                         "SELECT                                                               "+
                         "circuits.id,                                                         "+
                         "measures.watts *                                                     "+
                         "EXTRACT(epoch FROM (measures.created_at - lag(measures.created_at)   "+
                         "over (order by measures.created_at)))/3600 AS Wh,                    "+
                         "to_char(measures.created_at,'HH24') AS time_unit                     "+
                         "FROM                                                                 "+ 
                         "measures,                                                            "+
                         "circuits                                                             "+
                         "WHERE                                                                "+ 
                         "measures.created_at >= ? AND                                         "+
                         "measures.created_at <= ?                                             "+
                         "ORDER BY                                                             "+
                         "time_unit ASC ) AS stats                                             "+
                         "GROUP BY 2,3                                                          ",
                         date.beginning_of_day - 3.hours, date.end_of_day ])
  end

  def self.sum_energy_month(date)
    date = if date then date else Date.today end
    measures = Circuit.find_by_sql(["SELECT * FROM circuit_sum_day "+
                                  "WHERE                           "+
                                  "time_unit <= ? AND              "+
                                  "time_unit >= ?;                 ",
                                   date.end_of_month,
                                   date.at_beginning_of_month
                                   ])
    
    one_day_of_month_for_each_circuit_id = []
    days_in_month = (date.at_beginning_of_month..date.at_end_of_month)
    circuits_ids = Circuit.select('id').as_json.map!{|c| c['id']}
    
    days_in_month.each do |d|
      circuits_ids.each do |c|
        one_day_of_month_for_each_circuit_id << {"time_unit" => d.to_time.to_i, "wh" => 0, "id" => c}
      end
    end

        one_day_of_month_for_each_circuit_id.each do |circuit_day|
          measures.each.each do |m|
          if m.time_unit.to_time.to_i == circuit_day["time_unit"] && circuit_day["id"] == m.id
            circuit_day["wh"] = m.Wh
          end 
        end
        circuit_day["time_unit"] = DateTime.strptime(circuit_day["time_unit"].to_s,'%s').strftime("%d/%m/%y")
      end

       return one_day_of_month_for_each_circuit_id 
  end

  def self.sum_energy_year(date)
    if date then date else Date.today end
    Circuit.find_by_sql(["SELECT tmp.time_unit, stat.wh, stat.id
                          FROM(select to_char(DATE '2015-01-01' + (interval '1' month * generate_series(0,11)),'Mon') as time_unit) as tmp 
                          left outer join (
                          select
                          to_char(to_date(replace(time_unit,'-','/'), 'YYYY MM DD'),'Mon') as mon,
                          trunc(cast(sum(\"Wh\") AS numeric),2) as \"wh\",
                          id
                          from prv_7.circuit_sum_day
                          where time_unit > ?   
                          group by 1, 3) as stat
                          on tmp.time_unit = stat.mon",
                          date.at_beginning_of_year ])  
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
