class androidsdk  (
    $asdk_loc  = "http://dl.google.com/android"
    $asdk_version = "android-sdk_r23.0.2-linux"
){

    #Default Path
    $defpath   = "/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin"

    $modpath = "puppet:///modules/androidsdk"

    $packages = [
        'glibc.i686',
        'zlib.i686',
        'libstdc++.i686',
    ]

    package { $packages:
        ensure => installed
    }

    group { 'android-group':
        name => 'android',
        ensure => 'present',
    }

    # Download android SDK
    exec { 'fetch-androidsdk':
        command => "curl -o $asdk_version.tgz $asdk_loc/$asdk_version.tgz",
        user    => 'root',
        cwd     => "/root/",
        path    => $defpath,
        unless  => "ls /root/$asdk_version.tgz",
        timeout => 0,
    }

    # Extract android SDK
    exec { 'asdk-extract':
        command => "tar xzf /root/$asdk_version.tgz",
        user    => 'root',
        cwd     => "/opt",
        path    => $defpath,
        unless  => "ls -d /opt/android-sdk-linux",
        require => Exec['fetch-androidsdk']
    }

    exec { 'asdk-chgrp':
        command => "chgrp -R android /opt/android-sdk-linux",
        user    => 'root',
        cwd     => "/opt",
        path    => $defpath,
        require => [
            Exec['asdk-extract'],
            Group['android-group']
        ]
    }

    exec { 'asdk-gstick':
        command => 'find /opt/android-sdk-linux -type d -exec chmod g+s {} \;',
        user    => 'root',
        cwd     => "/opt",
        path    => $defpath,
        require => Exec['asdk-chgrp']
    }

    file { 'asdk-env':
        path => '/etc/profile.d/asdk.sh',
        owner => 'root',
        group => 'root',
        mode => 0644,
        source => "$modpath/asdk.sh"
    }
}
