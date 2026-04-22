#!/usr/bin/perl
use strict;
use warnings;
use Fcntl qw(O_RDWR);
use Errno qw(EIO EINTR);

sub hex_preview {
    my ($data, $max) = @_;
    $max ||= 64;
    my $len = length($data);
    my $slice = substr($data, 0, $max);
    my @bytes = map { sprintf("%02x", ord($_)) } split(//, $slice);
    return join(' ', @bytes) . ($len > $max ? " ..." : "");
}

my $dev = shift @ARGV or die "Usage: $0 /dev/tun0|/dev/tap0 [count] [wait_seconds]\n";
my $count = shift @ARGV || 1;
my $wait_seconds = shift @ARGV || 10;

sysopen(my $fh, $dev, O_RDWR) or die "Cannot open $dev: $!\n";

print "Opened $dev\n";
print "Waiting for up to $count frame(s)/packet(s)...\n";

for (my $i = 1; $i <= $count; $i++) {
    my $deadline = time() + $wait_seconds;

    while (1) {
        my $buf = '';
        my $n = sysread($fh, $buf, 4096);

        if (defined $n) {
            if ($n == 0) {
                die "EOF on $dev\n";
            }

            print "[$i] read $n byte(s)\n";
            print "[$i] hex: " . hex_preview($buf, 96) . "\n";
            last;
        }

        if ($! == EIO || $! == EINTR) {
            if (time() >= $deadline) {
                die "Timed out waiting for traffic on $dev\n";
            }
            select(undef, undef, undef, 0.25);
            next;
        }

        die "Read error on $dev: $!\n";
    }
}

close($fh);
print "Done.\n";
