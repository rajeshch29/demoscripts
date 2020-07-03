#!/usr/bin/perl
use strict;
use warnings;

use Net::SSH::Expect;

my $ssh = Net::SSH::Expect-> new (
        host => "rajesh-VirtualBox",
        password => "home",
        user => "rajesh",
        raw_pty => 1,
        timeout => 3
);

my $login_output=$ssh->login();
if ( $login_output =~ /Last/ )
{
   print "The login was successful \n";
   print "Get the details on remote server now \n";
   $ssh->send("uname -a");
   $ssh->send("uptime");
}
else
{
   die "Log in attempt failed with $! \n";
}
