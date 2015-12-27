#!/usr/bin/perl

#update the linux driver after a kernel update.
#Gregory at allsbe.com
#
#

@tools		=('make', 'gcc');
@xlibs		=('xorg-dev', 'xserver-xorg-dev');
$mykern 	= `uname -r`;
$purgenv	="apt-get -y purge fglrx nvidia-current nvidia-settings nvidia-current-dev nvidia-current-updates nvidia-current-updates-dev";
$get_headers	="apt-get -y install linux-headers-${mykern}";
$getdriver	="apt-get -y install nvidia-current nvidia-settings";
$ubuntudevtools	="apt-get -y install ubuntu-dev-tools";

print "This script will reinstall the nvidia driver and all required components.\n";
print "This script must be run as the super user or as a user with permission to install software!!!!\n";
print "Starting interactive install\n";
	open(startinst, "dpkg -l | awk {'print \$2'} | grep -i nvidia |")or die $!;
	$pkgcnt = 0;
		while ($startinst = <startinst>){
			next unless $startinst=~/\w+/;
			$pkgcnt++;
			push @nvpkg, $startinst;
			print "The following nvidia package appears to be installed: $startinst";
		}
		close(startinst);	
	
	print "Would you like to proceed with nvidia package removal (Y or N):";	
	$remans = <stdin>;
	chomp $remans;
	exit unless $remans =~ /y/i;
	print "purging old driver....";
	open (purge, "$purgenv | ") or die $!;
		while ($purge = <purge>){
		print "$purge";
		}
	close purge;
	
	foreach $tool (@tools){
		open (findtools, "which $tool |") or die $!;
			$gcccnt=0;
			while ($findtools = <findtools>){
			next unless $findtools =~ /\/\w+/;
			print "$tool found in $findtools\n";
			$gcccnt++;
			}
		close findtools;
		}
		if ($gcccnt = 0){
			print "Some tools appear to be missing, installing...";
			open (instdev, "${ubuntudevtools} |") or die $!;	
			while ($instdev = <instdev>){
				print "$instdev";
			}
		}
			close instdev;
		foreach $xdevtool (@xlibs){
			print "checking for xlibs\n";
			$xlib = 0;
				open (xcheck, "dpkg -l | awk {'print \$2'} | grep $xdevtool |") or die $!;
			while ($xcheck = <xcheck>){
			next unless $xcheck =~ /\w+/;
			print "found $xcheck";
			$xlib++;
			print "xlib count is $xlib";
			}
			close xcheck;
			print "xlib count is $xlib\n";
			if ($xlib == 0){
				print "installing x libraries....";
				open(instxlib, "apt-get -y install $xdevtool |") or die $!; 			
				while ($instxlib =<instxlib>){
				print $instxlib;
					}
				close instxlib;
				}	
			}
		open (kerncheck, "dpkg -l | awk {'print \$2'} | grep -i linux-headers-${mykern} |") or die $!;
			$headers = 0;
			while ($kerncheck = <kerncheck>){
			next unless $kerncheck =~ /\w+/;
			$headers++;
			print "headers value $headers";
			}
			close kerncheck;
			if ($headers == 0){
			print "installing kernel headers....";
		        open (instheader, "${get_headers} |") or die $!;
				while ($instheader = <instheader>){
				print $instheader;
				}
			close instheader; 
			}
		print "installing nvidia driver.....";
		open(nvdriverinst, "$getdriver |") or die $!;
			while ($nvdriverinst = <nvdriverinst>){
			print $nvdriverinst;
			}
		close nvdriverinst;
		print "driver install complete, would you like to reboot (Y or N)?";
	$reb = <stdin>;
	chomp $reb;
	exit unless $reb =~ /y/i;
	`reboot`;
