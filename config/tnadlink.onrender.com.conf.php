;<?php exit; ?>
;*** DO NOT REMOVE THE LINE ABOVE ***

[database]
type=postgresql
host="{SUPABASE_DB_HOST}"
port="{SUPABASE_DB_PORT}"
username="{SUPABASE_DB_USER}"
password="{SUPABASE_DB_PASSWORD}"
name="{SUPABASE_DB_NAME}"
persistent=false
protocol=https
schema="{SUPABASE_DB_SCHEMA}"
ssl=true

[webpath]
admin="https://tnadlink.onrender.com/admin"
delivery="https://tnadlink.onrender.com/delivery"
deliverySSL="https://tnadlink.onrender.com/delivery"
images="https://tnadlink.onrender.com/images"
imagesSSL="https://tnadlink.onrender.com/images"
api="https://tnadlink.onrender.com/api"

[ui]
applicationName="TN Ad Link"
headerLogoFilename="/custom/themes/tn-logo.png"
enabled=true
supportLink="mailto:admin@tnadlink.com"
dashboardEnabled=true

[geotargeting]
type=geoip
showUnavailable=false

[openads]
requireSSL=true
sslPort=443

[delivery]
cache=true
acls=true
aclsDirectSelection=true
obfuscate=false

[maintenance]
autoMaintenance=true
timeLimitScripts=1800

[store]
webDir="/var/www/html/public/var"

[allowedTags]
items[]="a"
items[]="b"
items[]="div"
items[]="font"
items[]="img"
items[]="strong"
