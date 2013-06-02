#!/usr/bin/perl

my $dirpath="/app/app/perl";
print $dirpath;

chdir($dirpath) or die "Cant chdir to $dirpath $!";
system("ls -lt");

system("perl ./stack_read02.pl");