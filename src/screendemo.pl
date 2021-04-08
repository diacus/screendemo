#!/usr/bin/perl -w

use strict;

sub get_geometry
{
  my $x;
  my $y,
  my $width;
  my $height;
  my $geometry;
  my $window_id;

  open (XPROP, "xprop -root |");
  while (<XPROP>) {
    $window_id = $1 if (/_NET_ACTIVE_WINDOW\(WINDOW\): window id # (\w+)/);
  }
  close(XPROP);

  open(WININFO, "xwininfo -id $window_id |");
  while (<WININFO>) {
    $x = $1 if (/Absolute.*X:\s+(\d+)$/);
    $y = $1 if (/Absolute.*Y:\s+(\d+)$/);

    $width = $1 if (/Width:\s+(\d+)$/);
    $height = $1 if (/Height:\s+(\d+)$/);
  }

  close(WININFO);

  $geometry = {
    'width' => $width,
    'height' => $height,
    'x' => $x,
    'y' => $y,
    'full' => qq(${width}x${height}+${x}+${y})
  };

  return $geometry;
}

sub screenkey
{
  my $args = shift;
  my $full_geometry;

  $full_geometry = $args->{'full'};

  exec "screenkey -g $full_geometry";
}

sub byzanz
{
  my $args = shift;
  my $x;
  my $y;
  my $width;
  my $height;
  my $duration;

  $x = $args->{'x'};
  $y = $args->{'y'};
  $width = $args->{'width'};
  $height = $args->{'height'};

  $duration = defined $ENV{'DURATION'} ? $ENV{'DURATION'} : '10';

  exec "byzanz-record -d $duration -x $x -y $y -w $width -h $height demo.gif";
}

sub spawn_function
{
  my $callback = shift;
  my $args = shift;
  my $pid;

  $pid = fork;

  if ($pid == 0)
  {
    $callback->($args);
  }
  else
  {
    return $pid;
  }
}

sub start_demo
{
  my $geometry;
  $geometry = get_geometry();

  spawn_function(\&screenkey, $geometry) unless (defined $ENV{NOKEYS});
  spawn_function(\&byzanz, $geometry);

  system("clear");
}

sub main
{
  my $command;

  $command = shift @ARGV;

  if ($command =~ /^start$/i)
  {
    start_demo();
  }
  elsif ($command =~ /^stop$/i)
  {
    system("pkill -f screenkey");
  }
  else
  {
    print "USAGE: $command \n";
    print "\tscreendemo start\n";
    print "\tscreendemo stop\n";
  }
}

main();
