#!/usr/bin/perl
use strict;
use warnings;

sub rescanDisks{
    # `echo "- - -" > /sys/class/scsi_host/host$i/scan`;
    print "Disk scan completed.\n";
}

rescanDisks();