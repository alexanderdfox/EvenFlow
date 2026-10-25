#!/usr/bin/env perl
use strict;
use warnings;
use Math::Trig;          # for sin()

# --- Vin: oscillating pump (100 Hz sine, sampled) ---
sub vin {
    my ($t, $amp, $freq) = @_;
    return $amp * sin(2 * pi * $freq * $t);
}

# --- D1 + OA1: precision check-valve + high-gain servo ---
# Ideal diode behavior enforced by the "op-amp" (we just take max(0, x))
sub precision_rectify {
    my ($x) = @_;
    return $x > 0 ? $x : 0;   # check valve + infinite-gain correction
}

# --- R1: flow restrictor / scale ---
sub restrict {
    my ($x, $r) = @_;
    return $x / $r;           # simple inverse relationship (analogy)
}

# Pipeline: generate → rectify → restrict → out
my $sample_rate = 1000;       # samples per second
my $duration    = 0.05;       # 50 ms of signal
my $amp         = 5.0;
my $freq        = 100;
my $R1          = 10;         # "10 kΩ" scaled down for numbers

for (my $i = 0; $i < $sample_rate * $duration; $i++) {
    my $t   = $i / $sample_rate;
    my $raw = vin($t, $amp, $freq);          # Vin
    my $rect = precision_rectify($raw);      # D1 + OA1
    my $out  = restrict($rect, $R1);         # R1

    printf "%.6f  %.4f\n", $t, $out;         # out pipe
}
