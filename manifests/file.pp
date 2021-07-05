define htpasswd::file (
  $file,
  $group = 'www-data',
){
    exec{"auth_file_${name}":
        path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        onlyif => "test ! -f ${file}",
        command => "install -g ${group} -m 660 /dev/null ${file}",
    }

}
