include devusr

class androidsdk  {

    $devusr = $devusr::username
    $devgrp = $devusr::devgroup

    #Default Path
    $defpath   = "/home/$devusr/AndroidSDK/tools:/home/$devusr/AndroidSDK/platform-tools:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin"

    #Android SDK Location
    $asdk_loc  = "http://dl.google.com/android"

    #Android SDK file name
    $asdk_version = "android-sdk_r23.0.2-linux"

    $modpath = "puppet:///modules/androidsdk"

    package { 'glibc.i686':
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
