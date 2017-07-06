#!/usr/bin/perl

use strict;
use warnings;
use POSIX;
use UBOS::Utils;

my $thermDev = {
    '/sys/class/thermal' => {
        'thermal_zone0/temp' => 'RPi on-chip'
    },
    '/sys/bus/w1/devices' => {
        '28-021501bb78ff/w1_slave' => 'Attic',
        '28-021501c3f9ff/w1_slave' => 'Hallway',
        '28-021501bbc8ff/w1_slave' => 'Office',
        '28-021501f6c6ff/w1_slave' => 'Server closet'
    }
};
my $gpioDev = 21;

my $temperatures = {};

foreach my $thermPath ( sort keys %$thermDev ) {
    foreach my $dev ( sort keys %{$thermDev->{$thermPath}} ) {
        my $desc    = $thermDev->{$thermPath}->{$dev};
        my $content = UBOS::Utils::slurpFile( "$thermPath/$dev" );
        my $temp    = '?';
        if( $content =~ m!t=(\d+)! ) {
            # W1 devices
            $temp = $1;
        } else {
            # on-chip
            $temp = $content;
        }
        $temperatures->{$desc} = $temp / 1000.0;
    }
}
my $fanOn = 0;
if( $temperatures->{'Server closet'} > 30 ) {
    if( $temperatures->{'Server closet'} - $temperatures->{'Office'} > 3 ) {
        $fanOn = 1;
    }
}

UBOS::Utils::myexec( "gpio mode $gpioDev out" );
UBOS::Utils::myexec( "gpio write $gpioDev $fanOn" );

printf "Fan is $fanOn (%.2f - %.2f = %.2f)\n", $temperatures->{'Server closet'}, $temperatures->{'Office'}, $temperatures->{'Server closet'} - $temperatures->{'Office'} ;

1;

