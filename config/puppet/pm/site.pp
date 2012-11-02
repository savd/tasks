node 'web.dev' {

}

node "db.dev" {

    exec { "instal repo":
        command => "zypper addrepo --repo http://download.opensuse.org/repositories/server:/database/openSUSE_12.2/server:database.repo",
        path => "${path}",
    }

    package { "mongodb":
        ensure => installed,
    }

}