create _user.
assign _user._userid = "test01"
       _user._password = encode("test01").
create _user.
assign _user._userid = "test'02"
       _user._password = encode("test02").
create _user.
assign _user._userid = "'test03'"
       _user._password = encode("test03").

message 'Users created'.
return '0'.
