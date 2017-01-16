find _Database-Feature 
    where _Database-Feature._DBFeature-ID = 5
      and _Database-Feature._DBFeature_Active = "1"
      and _Database-Feature._DBFeature_Enabled = "1"
    no-error.
if not avail _Database-Feature then return "100".

RETURN '0'.
