#!/usr/bin/perl -w
#
# proc-profiler.pl	Profile /proc/PID/stack and emit folded format for
#			flame graphs.
#
# USAGE: proc-profiler.pl [-C] {-p PID, -n name} duration
# See --help
#
# Copyright (c) 2017 Brendan Gregg.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# 22-Aug-2017	Brendan Gregg	Created this.

use strict;
use Getopt::Long;

sub usage {
	print <<USAGE_END;
USAGE: proc-profiler.pl [-C] {-p PID, -n name} duration
eg,
	proc-profiler.pl -p 181 10	# profile PID 181 for 10s, wall time
	proc-profiler.pl -cp 181 10	# profile PID 181 for 10s, CPU only
USAGE_END
	exit;
}

my $timezerosecs = 0;
my $frequency = 49;
my ($pid, $name);
GetOptions(
        'process|p=i'   => \$pid,
        'name|n'        => \$name,
) or usage();

if (defined $ARGV[0] and ($ARGV[0] eq "-h" || $ARGV[0] eq "--help")) {
        usage();
}
die "Need either -p or -n" if not defined $pid and not defined $name;
if (defined $name) {
	# XXX
	die "-n|--name not yet supported";
}
my $duration = 9999999;
$duration = int($ARGV[0]) if defined $ARGV[0];
my $interval = 1 / $frequency;
my $count = $duration * $frequency;

my @pids = $pid;	# XXX support multpile PIDs
my %stacks;

my $i = 0;
$SIG{INT} = sub { $i = $count; };	# on Ctrl-C, jump to final sample
for (; $i < $count; $i++) {
	foreach my $p (@pids) {
		if (not open FD, "/proc/$p/stack") {
			print STDERR "Process $p terminated. Ending profile.\n";
			goto DONE;
		}
		my @rawstack = <FD>;
		close FD;
		my @stack = ();
		foreach (@rawstack) {
			my ($addr, $func) = split;
			$func =~ s/\+.*//;
			unshift @stack, $func;
		}
		my $folded = join ";", @stack;
		$stacks{$folded}++;
	}
	select(undef, undef, undef, $interval);
}
DONE:

foreach my $folded (sort {$stacks{$b} <=> $stacks{$a}} keys %stacks) {
	print "$folded $stacks{$folded}\n";
}
