message "Test DB1".
find _file where _file-name eq 'tab1' no-lock no-error.
if not available _file then return '1'.
find _file where _file-name eq 'tab2' no-lock no-error.
if available _file then return '1'.
find _file where _file-name eq 'tab3' no-lock no-error.
if available _file then return '1'.
find _file where _file-name eq 'tab4' no-lock no-error.
if available _file then return '1'.
return '0'.
