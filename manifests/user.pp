#htpasswd
define htpasswd::user (
  $password,
  $file,
  $group      = 'www-data',
  $ensure     = present,
  $encryption = md5
){

  if ! defined(Package[apache2-utils]) {
    package { apache2-utils:
      ensure => present
    }
  }
    Exec {
        path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }

    htpasswd::file{"${name}": 
        file => $file,
        group => $group
    }  
  
    case $encryption {
        md5:        {   $enctype = "-m" }
        sha:        {   $enctype = "-s" }
        crypt:      {   $enctype = "-d" }
        plain:      {   $enctype = "-p" }
        default:    {   $enctype = "-m" } 
    }    

$dirname = regsubst($file, '/[0-9A-Za-z._-]+$', '')
    case $ensure {

        absent:     {
          $cmd = "htpasswd -b -D $file ${name}" 
          $cmd_check = "echo 1"
        }
        default:    {
          $cmd = "htpasswd -b ${enctype} ${file} ${name} '${password}'"
          $cmd_check = "md5sum $file > ${dirname}/sums; htpasswd -b ${enctype} ${file} ${name} '${password}'; md5sum -c /etc/nginx/sums"
        }
    }

    exec {"manage_user_${name}":
        path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        command => "${cmd}",
        unless  => $cmd_check,
        require => [ Htpasswd::File["${name}"], Package['apache2-utils'] ]
    }
}
