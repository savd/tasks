include rvm

$ruby_version = 'ruby-1.9.3'

node default {
    include resolver

    Resolv_conf[resolver] -> Service['Disable firewall'] -> Package[libyaml-devel] -> Exec['install rvm'] -> Rvm_system_ruby[$ruby_version]

    exec { 'install rvm':
        command => '/usr/bin/curl -L https://get.rvm.io | /bin/bash -s stable --ruby',
        unless => '/usr/bin/test -x /usr/local/rvm/bin/rvm',
    }

    service { 'Disable firewall':
        name => 'SuSEfirewall2_setup',
        ensure => stopped,
        enable => false,
    }

    resolv_conf { 'resolver':
        domainname  => 'dev',
        searchpath  => ['dev'],
        nameservers => ['192.168.3.20','10.0.0.1'],
    }

    rvm_system_ruby {$ruby_version:
        ensure => present,
        default_use => true,
        require => Exec['install rvm'],
    }

    rvm_gem {["$ruby_version/bundler", "$ruby_version/puppet"]:
        ensure => latest,
        require => Rvm_system_ruby[$ruby_version],
    }

    package { ['gcc-c++', make, libyaml-devel, zlib-devel,libopenssl-devel]:
        ensure => installed,
    }

    exec {'install gems':
        cwd => '/vagrant',
        path => '/usr/local/rvm/gems/ruby-1.9.3-p194@global/bin:/usr/local/rvm/gems/ruby-1.9.3-p194/bin',
        command => 'bundle install',
        unless => 'bundle check',
        require => [Package['gcc-c++',make], Rvm_gem["$ruby_version/bundler"]],
    }

    exec {'thin -p 4567 -d -R config.ru start':
        path => '/usr/local/rvm/gems/ruby-1.9.3-p194@global/bin:/usr/local/rvm/gems/ruby-1.9.3-p194/bin:/usr/bin',
        cwd => '/vagrant',
        unless => '/usr/bin/pgrep -f thin',
        require => Exec['install gems'],
    }
}