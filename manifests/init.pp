include devusr

class AndroidSDK {

    $devusr = $devusr::username
    $devgrp = $devusr::devgroup

    #Default Path
    $defpath   = "/home/$devusr/AndroidSDK/tools:/home/$devusr/AndroidSDK/platform-tools:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin"

    #Android SDK Location
    $asdk_loc  = "http://dl.google.com/android/adt/22.6.2"

    #Android SDK file name
    $asdk_version = "adt-bundle-linux-x86_64-20140321"

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
        command => "curl -o $asdk_version.zip $asdk_loc/$asdk_version.zip",
        user    => $devusr,
        cwd     => "/home/$devusr/distfiles",
        path    => $defpath,
        unless  => "ls /home/$devusr/distfiles/$asdk_version.zip",
        require => File['distdir']
    }

    # Extract android SDK
    exec { 'asdk-extract':
        command => "unzip /home/$devusr/distfiles/$asdk_version.zip",
        user    => $devusr,
        cwd     => "/home/$devusr",
        path    => $defpath,
        unless  => "ls -d /home/$devusr/$asdk_version",
        require => Exec['fetch-androidsdk']
    }

    # Move SDK to ~/AndroidSDK
    exec { 'asdk-move':
        command => "rm -rf AndroidSDK ; mv $asdk_version/sdk ./AndroidSDK",
        user    => $devusr,
        cwd     => "/home/$devusr",
        path    => $defpath,
        unless  => "ls -d /home/$devusr/AndroidSDK",
        require => Exec['asdk-extract']
    }
}
