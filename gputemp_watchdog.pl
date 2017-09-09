#!/usr/bin/perl
use strict;
use warnings;

my $temperature = 0;

print "Max temp:\n";
#read in defined max temp from STDIN (your terminal)
my $maxtemp = <STDIN>;

#remove the \n (Enter) from the end of the variable
chomp $maxtemp;

print "How many GPUs do you have installed?\n";
#read in gpu index from STDIN (your terminal)
my $gpuindex = <STDIN>;

#remove the \n (Enter) from the end of the variable
chomp $gpuindex;

my $index = 0;

while (1){
	#loop over all GPUs
	for ($index, $index < $gpuindex, $index += 1){
		#set $temperature to 0
		$temperature = 0;
		
		#call aticonfig to read out temp, save output in temperature.tmp (overwrite)
		system "aticonfig --odgt --adapter=$1 > temperature.tmp";
		
		#read in temperature.tmp
		open(TEMPERATURE, "<", "temperature.tmp") or die("Could not open temperature.tmp.");

		#read in all lines of temperature.tmp one by one 
		while (<TEMPERATURE>){
			#look for defined regex (search for temperature value), saved in $1 (defined by the brackets)
			$_ =~ m/Temperature\s-\s(\d*)\.\d*\sC/g;

			#check whether the RegEx found something, print result
			if (defined $1){
				print "Current temperature of GPU ".$index." is ".$1."\n";
				$temperature = $1;
			}
		}
		close(TEMPERATURE);

		#check whether measured temperature exceeds max temperature
		if ($temperature > $maxtemp){
			#directly shutdown the system
			print "Shutting down system\n";
			#system "sudo shutdown now";
			open(LOG, ">>", "log.txt");
			print LOG localtime." System shutdown. Temerature on GPU ".$index" exceeded defined max temperature: ".$temperature."° C - ".$maxtemp."° C\n";
			close(LOG);
			sleep 5;
			system "sudo shutdown now";
		}
	}
	#wait 5 seconds
	sleep 5;
	$index = 0;
}
