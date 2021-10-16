select h.vessel||','||
   h.haul||',' ||
   h.cruise||',' ||
   h.nmfs_area                   ||','||
   to_char(h.haul_date,'mm')     ||','||
   to_char(h.haul_date,'dd')     ||','|| 
   to_char(h.haul_date,'yyyy')   ||','||
   to_char((h.latdd_end+h.latdd_start)/2,'0999.999') ||','||
   to_char((h.londd_end+h.londd_start)/2,'09999.999') ||','||
   h.vessel_type                 ||','||
   h.official_total_catch        ||','||
   x.extrapolated_weight         ||','||
   x.extrapolated_number         ||','||
   h.nmfs_area      			||','|| 
   h.gear_type
   
 from 
   current_haul  h, 
   current_spcomp  x
where
  /*join between domestic_age and domestic_hauls trunc(h.latitude/100)+ h.latitude-(trunc(h.latitude/100) ||','|| trunc(h.longitude/100)||','|| */      
  h.haul_join=x.haul_join and
  /*x.species =202 and*/
  x.species = 140 and
  h.year between 1954 and 2020 and  
  h.nmfs_area between 500 and 539 ;

