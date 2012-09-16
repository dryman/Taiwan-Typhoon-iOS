#!/usr/bin/env perl
use 5.010;
use English;

undef $INPUT_RECORD_SEPARATOR;  # disable input seprator "\n"
open my $fh, "ty_infos.js";
$_ = <$fh>;                     # read endire file as string into $_

/\[.+?\];/s;                    # /s modifier let '.' match "\n"
                                # +? match not greedly
say $MATCH;
