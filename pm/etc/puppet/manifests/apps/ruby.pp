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

    file { "/root/.gemrc":
        content => "gem: --no-ri --no-rdoc\n",
        mode => "0640",
        owner => "root",
    }

}