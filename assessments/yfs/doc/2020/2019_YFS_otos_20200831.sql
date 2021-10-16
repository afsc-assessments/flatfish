SELECT --First, get biological specimen data.
         (SELECT common_name FROM norpac.atl_lov_species_code WHERE species_code = sp.species) AS species_name, 
         sp.species, sp.barcode, sp.sex, sp.length AS length_cm, sp.weight AS weight_kg, sp.age, 
         
         --Next, get vial location information.
         nr.rack_sequence, nr.location AS rack_location, ov.x_column, ov.y_row,
         
         --Get haul level data.
         sp.haul_offload AS haul_number, dh.haul_join, dh.retrieval_date, dh.deployment_date, sp.nmfs_area, sp.gear, gt.description AS gear_description, vt.vessel_type, vt.description AS vessel_type_description,
         DECODE(dh.haul_purpose_code, 'R16', 'Halibut decksorting EFP', 'CA', 'Standard') AS sampling_platform,
         dh.CDQ_code,
         
         --Get predominant species for haul.  See function for details, if desired.
         DECODE(norpac.predominant_species_debriefed(xhaul_join => sp.haul_join),
                'O', 'OTHER',
                'P', 'Pollock',
                'A', 'Atka Mackerel',
                'C', 'PCod',
                'K', 'Rockfish',
                'S', 'Sablefish',
                'W', 'Kam/Arrow/Turbot',
                'F', 'Flatfish',
                'H', 'Halibut',
                norpac.predominant_species_debriefed(xhaul_join => sp.haul_join)) AS predominant_species_in_haul,
                
         --Get more haul-level data.       
         sp.latdd_end, sp.latdd_start, sp.londd_end, sp.londd_start, sp.bottom_depth_fathoms,    
         
         --Get other general identifiers (vessel name, etc)
         sp.cruise, sp.permit, (SELECT name FROM norpac.atl_vessplant_v WHERE permit = sp.permit) AS vessel_or_plant, sp.year 
    FROM obsint.debriefed_age_squash_sp_type sp
    JOIN obsint.debriefed_haul dh
      ON dh.haul_join = sp.haul_join
    JOIN norpac.atl_lov_gear_type gt
      ON gt.gear_type_code = sp.gear
     AND gt.geartype_form = 'H'
    JOIN norpac.atl_lov_vessel_type vt
      ON vt.vessel_type = dh.vessel_type    
    LEFT OUTER JOIN norpac.otolith_vials ov
      ON ov.barcode = sp.barcode
    LEFT OUTER JOIN norpac.racks nr
      ON nr.rack_sequence = ov.rack_sequence
   WHERE sp.species = 140 --yellowfin sole
     AND sp.year = 2019 
     AND sp.type_1_otolith = 'Y'
 
 
