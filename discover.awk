function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
BEGIN{
}

{
	ip=trim( substr($0,1,15) )
	mac=trim(substr($0,18,18))
	print "INSERT INTO red_discover(ip, mac, fechahora) VALUES('"ip"','"mac"','"date"');"
}

END{
}