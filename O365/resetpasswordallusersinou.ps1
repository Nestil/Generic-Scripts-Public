#Nestil Script
DSQUERY user "OU=myOU,OU=myUsers,DC=myDomain,DC=loc" -limit 0 | DSMOD user -pwd <insert new password here>