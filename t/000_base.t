#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use Test::More tests => 6;
use File::Path;

BEGIN {
  unshift @::INC, "$FindBin::Bin/lib";
};

use MyHttpServer;

my $outdir  = "$FindBin::Bin/tmp";

rmtree($outdir);
mkdir $outdir;
chdir $FindBin::Bin || die;

my $pid;

{
  local *STDOUT;
  my $out="";
  open(STDOUT,'>',\$out);
  $pid = MyHttpServer->new(8080)->background();
}

# Checking command
my $cmd="../download_files --outdir $outdir --recompress yes";
my $out=`$cmd`;
ok($? == 0,"Checking download with recompression") || print $out;
ok((-f "$outdir/Test-Simple-1.001014.tar.bz2"), "Checking downloaded file exists"); 

# Checking file content
my $tar = "tar tf $outdir/Test-Simple-1.001014.tar.bz2";
`$tar`;
ok($? == 0,"Checking extraction $tar");
ok((-f "$outdir/patch1.diff"),"Checking patch1");
ok((-f "$outdir/patch2.diff"),"Checking patch2");

# checking cleanup (3 files + dir)
ok(rmtree($outdir) == 4,"Checking cleanup");

# cleanup
kill 15, $pid;
waitpid $pid, 0;

exit 0;
