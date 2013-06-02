#!/usr/bin/perl -w
use strict "vars";
use warnings;
#print "\nBEGIN ENV in jm002a.pl = ". $ENV{'WTF'} . "END ENV"; #exit;

my $myOutpath= '.';
my $MSG;
my $fn =  "$myOutpath/msg.txt";
my $fnMsg = $ARGV[0] || "msg.txt";
$fnMsg = "$myOutpath/".$fnMsg;

open($MSG, q{<}, "$fnMsg") || die print "can not open($fnMsg)$!";

while (<$MSG>)
{
   print $_;
}
close $MSG;
