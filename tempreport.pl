#!/usr/bin/perl

use strict;
use warnings;
use POSIX;
use UBOS::Utils;

my $thermPath = '/sys/bus/w1/devices'; # /28-021501*/w1_slave
my $thermDev = {
    '28-021501bb78ff' => 'Attic',
    '28-021501c3f9ff' => 'Hallway',
    '28-021501bbc8ff' => 'Office',
    '28-021501f6c6ff' => 'Server closet'
};
my $gpioDev = {
    '21' => 'Server closet fan'
};

my( $second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings ) = gmtime( time());
printf "%15s: %04d-%02d-%02d %02d:%02d:%02d\n", 'Current time', 1900+$yearOffset, $month+1, $dayOfMonth, $hour, $minute, $second;

foreach my $dev ( sort keys %$thermDev ) {
    my $desc    = $thermDev->{$dev};
    my $content = UBOS::Utils::slurpFile( "$thermPath/$dev/w1_slave" );
    my $temp    = '?';
    if( $content =~ m!t=(\d+)! ) {
        $temp = $1;
    }

    printf "%15s: %d.%1d\n", $desc, floor( $temp / 1000 ), floor( ( $temp % 1000 )/100 + 0.5 );
}
foreach my $dev ( sort keys %$gpioDev ) {
    my $desc = $gpioDev->{$dev};
    my $content;
    UBOS::Utils::myexec( "gpio read $dev", undef, \$content );
    my $state = ( $content =~ m!1! ) ? 'on' : 'off';

    print( "$desc is: $state\n" );
}

1;

