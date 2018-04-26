use strict;
use Nix::Store;
use Time::HiRes qw(gettimeofday tv_interval);

my $hashPart = "00000000000000000000000000000000";
my $startTime = [gettimeofday];

for (my $i = 0; $i < 1_000_000; $i++) {
    queryPathFromHashPart($hashPart);
}

my $elapsedTime = tv_interval($startTime);
print("zeroed out hash: $elapsedTime\n");

my $hashPart = "lp7x6ziq5b2zihgad0i8a28xxvz5vnrr";
my $startTime = [gettimeofday];

for (my $i = 0; $i < 1_000_000; $i++) {
    queryPathFromHashPart($hashPart);
}

my $elapsedTime = tv_interval($startTime);
print("python3 hash: $elapsedTime\n");

my $hashPart = "lp7x6ziq5b2zihga0000000000000000";
my $startTime = [gettimeofday];

for (my $i = 0; $i < 1_000_000; $i++) {
    queryPathFromHashPart($hashPart);
}

my $elapsedTime = tv_interval($startTime);
print("half-zeroed python3 hash: $elapsedTime\n");
