class androidsdk (
    $devusr   = "amarks",
    $devgrp   = "amarks"
){

    #Default Path
    $defpath   = "/bin:/usr/bin:/sbin:/usr/sbin"

    #Android SDK Location
    $asdk_loc  = "http://dl.google.com/android/adt/22.6.2"

    #Android SDK file name
    $asdk_version = "adt-bundle-linux-x86_64-20140321"

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
        command => "wget $asdk_loc/$asdk_version.zip",
        user    => $devusr,
        cwd     => "/home/$devusr/distfiles",
        path    => $defpath,
        unless  => "ls /home/$devusr/distfiles/$asdk_version.zip",
        require => File['distdir']
    }
}
