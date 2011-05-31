# http://bitfieldconsulting.com/puppet-and-mysql-create-databases-and-users
class osqa_db {
  package { "mysql-server": ensure => installed }
  package { "mysql-common": ensure => installed }

  service { "mysql":
    enable => true,
    ensure => running,
    require => Package["mysql-server"],
  }

  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$mysql_password status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $mysql_password",
    require => Service["mysql"],
  }

  define mysqldb( $user, $password ) {
    exec { "create-${name}-db":
      unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
      command => "/usr/bin/mysql -uroot -p$mysql_password -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
      require => Service["mysql"],
    }
  }
### End of mysql set-up
	mysqldb { "osqa":
 		user => 'osqa', 
		password => $osqa_password, 
	}

}

# With respect to instructions. the site's folders
# will be created under /home
class osqa_folders {
	file { '/home/osqa/':
		mode => 0644,
		owner => www-data,
		group => www-data,
		ensure => directory,
	}

	file { '/home/osqa/osqa-server/':
		mode => 0644,
		owner => www-data,
		group => www-data,
		ensure => directory,
		require => File["/home/osqa"],
	}

	file { '/home/osqa/osqa-server/osqa.wsgi':
		source  => 'puppet:///modules/site_module/osqa.wsgi',
		owner => www-data,
		group => www-data,
		mode    => '640',
		require => File["/home/osqa/osqa-server/"],
	}

	file { '/etc/apache2/sites-available/osqa':
		source  => 'puppet:///modules/site_module/apache_osqa',
		mode    => '640',
		owner => www-data,
		group => www-data,
		require => File["/home/osqa/osqa-server/"],
	}

	exec { '/bin/ln -sf /etc/apache2/sites-available/osqa /etc/apache2/sites-enabled/050-osqa':
		require => File ['/etc/apache2/sites-available/osqa']
	}
}
class osqa_http {
  package { "apache2": ensure => installed }
  package { "libapache2-mod-wsgi": ensure => installed }
  
}

class osqa_additional_packages { 
  package { "python": ensure => installed }
  package { "python-setuptools": ensure => installed }
  package { "python-mysqldb": ensure => installed }
}

class osqa {
	include osqa_folders 
	include osqa_db
	include osqa_http
	include osqa_additional_packages
}
