#!/usr/bin/perl -W
use strict;
use warnings;

#use Modern::Perl;

use LWP::UserAgent;
use HTTP::Request;

use Encode;
use utf8;

use POSIX qw(strftime);
my $date = strftime "%d.%m.%Y", localtime;

my $URL = 'http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt?date='.$date;

#my $agent = LWP::UserAgent->new(env_proxy => 1,keep_alive => 1, timeout => 30);
my $agent = LWP::UserAgent->new();
#$agent->proxy(['http'], 'http://my.proxy.com:3128/');
#my $header = HTTP::Request->new(GET => $URL);
#my $request = HTTP::Request->new('GET', $URL, $header);
my $request = HTTP::Request->new('GET', $URL);
my $response = $agent->request($request);
#print $response->content;

my $logfile = "kurz.txt";

# Check the outcome of the response
if ($response->is_success){
    #print "URL:$URL\nHeaders:\n";
    #print $response->headers_as_string;
    #print "\nContent:\n";
    #print $response->as_string;
    #open(LOGFILE, ">$response->content", $LOGFILE) or die("Could not open log file.");
    open(LOGFILE, ">$logfile") or die("Could not open log file.");
    print LOGFILE $response->content;
    close(LOGFILE);
}elsif ($response->is_error){
    print "Error:$URL\n";
    print $response->error_as_HTML;
}

#print "Content-type: text/html; charset=windows-1250\n\n";
open(LOGFILE, $logfile) or die("Could not open log file.");
<LOGFILE>;
<LOGFILE>;
#print "<html>";
#print "<body>";
#print "\n";
my %kurzy;
while ( <LOGFILE> )
{
    my $line = $_;
    chomp($line);
    my ($zeme,$mena,$mnozstvi,$kod,$kurz) = split(/\|/, $line, 5);
    $kurzy{"$kod"} = "$kurz";
#   print "<div>$kod $kurz</div>\n";
}
my $key;
foreach $key (sort keys (%kurzy)) {
#    print '<div>', $key, ' ', $kurzy{$key}, "</div>\n";
    print $key, ' ', $kurzy{$key}. "\n";
}
#print "</body>";
#print "</html>";
close(LOGFILE);
# vim:foldmethod=marker:ts=4:sw=4:noexpandtab
