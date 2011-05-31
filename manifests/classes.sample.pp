import "osqa.pp"
Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin' }

class site_name {
	$mysql_password = "PLACE_MYSQL_ROOT_PASSWORD_HERE"
	$osqa_password  = "PLACE_MYSQL_ROOT_PASSWORD_HERE"
	include osqa 
	
	# Additional configuration for specific site
}
