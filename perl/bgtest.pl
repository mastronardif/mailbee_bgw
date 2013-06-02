#!/usr/bin/perl
use strict;

my $fn = "mylog.txt";

while (1)
{
  my $rightnow = time();
  open FILE, "+>>", $fn or die "can not open($fn)$!";
  print "$rightnow YIKES ... \n";
  
  print FILE "$rightnow YIKES ... \n";
  sleep(25);
  close (FILE);
}

