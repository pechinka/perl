#!/usr/bin/perl -W
##############################################################################
#
# File   :  kurz
# History:  04-feb-2014 (pohlp) code tidy and comments added
#           05-jan-2014 (pohlp) first implementation
#
##############################################################################
#
# returns list of foreign exchange rates for Czech koruna (CZK) currency 
#
##############################################################################
use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;

use Encode;
use utf8;

use POSIX qw(strftime);
my $date = strftime "%d.%m.%Y", localtime;

my $URL = 'http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt?date='.$date;

my $agent = LWP::UserAgent->new();
my $request = HTTP::Request->new('GET', $URL);
my $response = $agent->request($request);

my $logfile = "kurz.txt";

if ($response->is_success)
{
    open(LOGFILE, ">$logfile") or die("Could not open log file.");
    print LOGFILE $response->content;
    close(LOGFILE);
}
elsif ($response->is_error)
{
    print "Error:$URL\n";
    print $response->error_as_HTML;
}

open(LOGFILE, $logfile) or die("Could not open log file.");
<LOGFILE>; # jump a line
<LOGFILE>; # jump a line

my %kurzy;
while ( <LOGFILE> )
{
    my $line = $_;
    chomp($line);
    my ($zeme,$mena,$mnozstvi,$kod,$kurz) = split(/\|/, $line, 5);
    $kurzy{"$kod"} = "$kurz";
}

close(LOGFILE);

open(LOGFILE, ">", $logfile) or die("Could not open log file.");

my $key;
foreach $key (sort keys (%kurzy))
{
    print $key, ' ', $kurzy{$key}. "\n";
}

close(LOGFILE);

# vim:foldmethod=marker:ts=4:sw=4:noexpandtab