rcode-info:file-name = "build/file1.r".
if (rcode-info:languages ne '<unnamed>,French,German') then return '1'.
rcode-info:file-name = "build/dir1/file2.r".
if (rcode-info:languages ne '<unnamed>,French,German') then return '2'.

return '0'.
