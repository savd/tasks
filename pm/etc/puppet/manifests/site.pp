import "apps/ruby.pp"

node "web.dev" {
    $project = hiera("project")
    $root = hiera("document_root")

    #Dependencies
    $ruby = hiera("ruby_version")
    $packages = hiera_array("packages")
    $gems = hiera_array("gems")
    $gemdir = "/usr/local/rvm/gems/${ruby}@global"

    #Stages
    Package[$packages] -> Rvm_gem[$gems] -> Exec["rake run"]

    package { $packages: ensure => installed }

    class { "ruby":
        version => "${ruby}",
        gems => $gems,
    }

    #Start service with correct ruby version
    exec { "rake run":
        path => "${gemdir}/bin:$path",
        cwd => "${root}",
    }
}

node "db.dev" {

    Exec["install repo"] -> Package["mongodb"]

    exec {
        "install repo":
            command => "zypper addrepo -G --repo http://download.opensuse.org/repositories/server:/database/openSUSE_12.2/server:database.repo",
            path => "${path}",
            unless => "zypper lr|grep server_database",
    }

    package { "mongodb": ensure => installed }

}