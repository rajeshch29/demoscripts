#!/usr/bin/perl
use strict;
use warnings;
use Time::localtime;
use Term::ANSIColor;

chomp( my $user = `whoami`);
chomp(my $oldBlk = `lsblk -n | awk '{print \$1}' |grep ^sd`);
print "\n*************************************************************";
print "\n \tScanning for the new disk.\n";
print "\n*************************************************************";
print `/pkg/esg/bin/rescan-scsi-bus.sh`;
chomp(my $newBlk = `lsblk -n | awk '{print \$1}'; |grep ^sd`);
my $newDisks= "";
if($oldBlk eq $newBlk){
	print color("red"),"\nNo new disks are available.\n", color("reset");
	print "Press 'y' to continue or press 'n' to exit: ";
	chomp(my $bool = <STDIN>);
	if($bool ne 'y'){
		print "\nExiting from the script...\n";
		exit;
	}
	print "\n********************Available Disks in this Server are:*********************\n";
	print "$newBlk";
	print "\nEnter new disk or disks.\nSaperate with spaces for multiple disks:Ex:-sdb sdc and so on\nPlease enter disks as above example: ";
	chomp($newDisks = <STDIN>);
}
else{
diskDiff($oldBlk, $newBlk);
chomp $newDisks;
my $rev = reverse($newDisks);
chomp($rev);
$newDisks = reverse($newDisks);
$newDisks =~ y/\n/ /; #Replace new line with white space
print "\nAvailable Disks in this Server is:\n";
print "$newBlk";
print "\n----------------------------------NEW SISK(s)------------------------------------\n";
print color("yellow"),"Available new disk(s) are : $newDisks", color("reset");
print "\nPress 'y' to continue with above new disk(s) or Press 'n' to change the disk(s): ";
chomp(my $aa = <STDIN>);
if($aa eq 'n'){
	print colored ("\nEnter the new disk(example:-sdb or sdc): ", 'yellow on_magenta');
	chomp($newDisks = <STDIN>);
	}
print "\n---------------------------------------------------------------\n";
}
#*****************************[BEGIN]NEW DISKS VALIDATION*************************

my @alldisks = split(' ', $newDisks);
my $diskcnt = @alldisks;
my $star = 0;
while($diskcnt > 0){
	if($alldisks[$star] =~ /sda[0-9]?/)
	{
		print color("red"), "$alldisks[$star] is a primary OS disk.\nExiting from the script...Please try again...\n", color("reset");
		exit;
		}
		chomp(my $out = `ls /dev/$alldisks[$star]`);
		if($out eq "/dev/$alldisks[$star]"){
			#print "$alldisks[$star] is available\n";
		}
		else{
			print color("red"),"$alldisks[$star] is not available\nExiting from the script...Please try again...\n", color("reset");
			exit;
		}
		$diskcnt = $diskcnt - 1;
		$star = $star + 1;
}

#*****************************[END]NEW DISKS VALIDATION*************************

my $tm=localtime;
my ($day,$month,$year)=($tm->mday,$tm->mon,$tm->year);
my $fn = "fstab" . $day . $month . $year;
print "Enter no. of volumes you want to create: ";
chomp(my $num = <STDIN>);
if ($num !~ /^[+-]?\d+$/)
{
print "$num is not a number. Please try again...\nExiting from the script...\n";
exit;
}
print color('cyan');
print "\nEnter the details of all the volumes in the below format.\n<size>,<Mount_point> and seperated by space for each volume set.\nExample: 50G,/opt/min/oradata 20G,/opt/min/oravol and so on.\nGive space after each volume set: ";
print color("reset");
print color("green");
chomp(my $alldata = <STDIN>);
print color("reset");
my @allvol = split(' ', $alldata);
my $cnt = @allvol;
if($num != $cnt){
print "\n Mismatched the no. of volumes.\tHence exiting from the script...\n";
exit;
}

#Taking fstab file backup
print "\n************************************************\n Taking backup of fstab.\n";
`cp -p /etc/fstab /etc/$fn`;
print "\n************************************************\n";
#**************************[BEGIN]VOLUME VALIDATION*************************
foreach my $n (@allvol){
	print "$n\n";
	my @vol = split(',', $n);
	if(scalar @vol !=2){
	print "Invalid arguments! Please enter size and mountpoint.\n";
	exit;
	}
	elsif($vol[0] !~ /[0-9]+(G|M)$/){
	print color("red"),"$vol[0] is Invalid size. The format should be <num><G|M>.\nEx:- 10G or 50M.\n", color("reset");
	exit;
	}
	elsif($vol[1] !~ /\/[a-z]{3}(\/[a-z]+){1,2}/){
	print color("red"),"$vol[1] is invalid mountpoint format. Please enter as below example.\nEx:- /opt/mis/oradata or /opt/mis/log\n", color("reset");
	exit;
	}
}
#/\/[a-z]{3}(\/[a-z]+){1,2}/ is for mountpoint pattern
#/[0-9]+(G|M)$/ is for size pattern
#**************************[END]VOLUME VALIDATION*************************
#--------------------------Bringing disks to LVM--------------------------
#my @alldisks = split(' ', $newDisks);
$diskcnt = @alldisks;
$star = 0;
while($diskcnt > 0){
	print `/sbin/pvcreate /dev/$alldisks[$star]`;
	print "\n*************************************************************\n";
	if($star == 0){
		print `/sbin/vgcreate vg011 /dev/$alldisks[$star]`;
	}
	else{
		print `/sbin/vgextend vg011 /dev/$alldisks[$star]`;
	}
	$diskcnt = $diskcnt -1;
	$star = $star + 1;
}

my $i = 0;
while( $num > 0){
	my @vol = split(',', $allvol[$i]);
	`mkdir -p $vol[1]`;
	my($last_match) = $vol[1] =~ m/.*\/(.*?)$/;
	my $lv = "lv_" . $last_match;
	if($num > 1){
		`/sbin/lvcreate -n $lv -L $vol[0] vg011`;
	}
	else{
		`/sbin/lvcreate -n $lv -l 100%FREE vg011`;
	}
	$num = $num - 1;
	$i = $i + 1;
	print `/sbin/mkfs.ext4 /dev/vg011/$lv`;
	open(MYFILE, '>>/etc/fstab');
	print MYFILE "/dev/vg011/$lv	$vol[1]	ext4	defaults	2	2\n";
	close(MYFILE);
	`/bin/mount -a`;
	print "\nMounted volume $vol[1] successfully.\n";
}
print "\n**************************Check the below mounted volumes.*************************\n";
print color("green"),`df -h`, color("reset");
print "\n";

#-----------------------------Method for Diff--------------------------#
#code reference: https://scheinast.eu/perl/perl-print-string-difference/
sub diskDiff{
my ($s1, $s2) = @_;
 
my @s1 = split(//, $s1);
my @s2 = split(//, $s2);
while (@s1) {
 
    if (defined $s1[0] and defined $s2[0]) {
    	if($s1[0] eq $s2[0]){
			shift @s1;
		}else{
			shift @s1;
		}
    }elsif(defined $s1[0]){
    	shift @s1;
    }
    shift @s2;
}
print "\n";
 
@s1 = split(//, $s1);
@s2 = split(//, $s2);
while (@s2) {
 
    if (defined $s2[0] and defined $s1[0]) {
		if($s2[0] eq $s1[0]){
			shift @s2;
		}else{
			shift @s2;
		}
    }elsif(defined $s2[0]){
    	#print color("red"),shift @s2, color("reset");
		$newDisks = $newDisks . shift @s2;
    }
    shift @s1;
}
print "\n";
}