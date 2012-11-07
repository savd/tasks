#Defaults
Exec { logoutput => 'on_failure', path => "$bin" }


class ruby($version, $gems) {
    include rvm

    Rvm_system_ruby[$version] -> Rvm_gemset["$version@global"] -> Rvm_gem[$gems]

    #Setup RVM
    rvm_system_ruby { $version:
        ensure => present,
        default_use => true,
    }

    rvm_gemset { "$version@global": ensure => present }

    rvm_gem { $gems:
        ruby_version => "$version@global",
        ensure => installed,
    }

}

define add_host($name, $ip) {
    host { "${name}":
       ensure => present,
       ip => "${ip}",
       name => "${name}",
    }
}

#We have to provide some sane defaults for managed host on the first run when init.pp applied
node default {

    File["/etc/puppet/puppet.conf"] -> Host["pm.dev"] -> Cron["apply puppet manifests"] -> Service["cron"]

    add_host { "pm.dev":
        name => "pm.dev",
        ip => "192.168.64.2",
    }

    file { "/etc/puppet/puppet.conf":
        content => "[agent]\nserver=pm.dev\n",
        ensure => present,
        owner => "root",
        mode => "0644",
    }

    cron { "apply puppet manifests":
        command => "puppet agent -to",
        user => "root",
        minute => "*",
        notify => Service["cron"],
    }

    service { "cron":
        ensure => running,
        enable => true,
    }

}

#Special treat for Puppet Master
node 'pm.dev' {
    $gemdir = "/usr/local/rvm/gems/1.9.3-p194@global"

    Package["ccache"] -> Package["puppet"] -> User["puppet"] -> Exec["puppet master"]

    package { [facter, hiera, hiera-puppet, puppet]:
        provider => gem,
        ensure => installed,
    }

    user { puppet: ensure => present }

    package { ["ccache"]: ensure => installed }

    exec {
        "puppet master":
            unless => 'lsof -i4tcp:8140',
            path => "$gemdir/bin:$path";
        "restart puppet":
            command => "pkill -f puppet",
            path => "${path}",
            notify => Exec["puppet master"],
            refreshonly => true;
    }

    file {"/etc/puppet/autosign.conf":
        content => "*.dev\n",
        ensure => present,
        mode => "0644",
    }

    add_host { "web.dev":
        name => "web.dev",
        ip => "192.168.64.3",
    }

    add_host { "db.dev":
        name => "db.dev",
        ip => "192.168.64.4",
    }

}
