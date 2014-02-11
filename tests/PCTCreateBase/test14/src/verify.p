&scoped-define largedb testlarge
&scoped-define relativedb testrel

find {&largedb}._Database-Feature 
    where {&largedb}._Database-Feature._DBFeature-ID = 5
      and {&largedb}._Database-Feature._DBFeature_Active = "1"
      and {&largedb}._Database-Feature._DBFeature_Enabled = "1"
    no-error.
if not avail {&largedb}._Database-Feature then return "100".

for each {&relativedb}._AreaExtent:
    if not {&relativedb}._AreaExtent._Extent-path begins "." then return "101".
end.

RETURN '0'.
