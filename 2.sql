SELECT * FROM (
SELECT 
  circuits.description, 
  measures.watts, 
  measures.created_at,
  row_number() OVER () as rnum
FROM 
  public.measures, 
  public.circuits
WHERE 
  circuits.id = measures.circuit_id AND
  circuits.user_id = 4
ORDER BY
  measures.created_at ASC ) AS stats
WHERE
mod(rnum,5) = 0;
