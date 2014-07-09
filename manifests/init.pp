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

    case $::operatingsystem {
        freebsd: {
            $pkg_dep = ['swt' ]
            $pkg_provider = pkgng

            # Install dependancies
            package { $pkg_dep:
                ensure   => installed,
                provider => $pkg_provider
            }
        }
    }


    # Make distfiles directory
    file { 'distdir':
        path => "/home/$devusr/distfiles",
        ensure => directory,
        mode => 0755,
        owner => $devusr,
        group => $devusr
    }

    # Download android SDK
    exec { 'fetch-androidsdk':
        command => "curl -o $asdk_version.tgz $asdk_loc/$asdk_version.tgz",
        user    => $devusr,
        cwd     => "/home/$devusr/distfiles",
        path    => $defpath,
        unless  => "ls /home/$devusr/distfiles/$asdk_version.tgz",
        timeout => 0,
        require => File['distdir']
    }

    # Extract android SDK
    exec { 'asdk-extract':
        command => "tar xzf /home/$devusr/distfiles/$asdk_version.tgz",
        user    => $devusr,
        cwd     => "/home/$devusr",
        path    => $defpath,
        #unless  => "ls -d /home/$devusr/$asdk_version",
        require => Exec['fetch-androidsdk']
    }
}
