#!/usr/bin/perl -W

use strict;
use warnings FATAL => 'all';

use Encode;
use utf8;

use Data::Dumper;

my $debug = 0;
my $fancy_output = 1;

# parse ini file into nice hash structure
sub parse_ini_file
{
    my $path = shift;
    my $struct = { };
    my $fh;

    open($fh, '<', $path)
        or die("$path: $!");
    my @lines = <$fh>;
    chomp @lines;
    close $fh;

    foreach my $line ( @lines )
    {
        next if $line =~ m/^$/;
        unless ( $line =~ m#^(.+):(.+)=(http://.*)$# ) {
            warn("Invalid line: '$line'");
            next;
        } # asd
        my $item = uc( $1 );
        my $shop = lc( $2 );
        my $link = $3;
        $struct->{"$1"}->{"$2"} = $3;
    }

    print Dumper( $struct ) if $debug;
    return $struct;
}

sub fetch_url
{
    my $url = shift;
    my @page;

    print "fetching $url\n" if $debug;

    #if ( $url =~ m#mironet.cz# ) {
    #    print "mironet";
    #    @page = `wget --remote-encoding=utf-8 -qO- $url`;
    #} elsif ( $url =~ m#czc.cz# ) {
    #    print "czc";
        @page = `wget -qO- $url`;
    #}
    die("failed to get $url") if $?;
    chomp @page;
    return @page;
}

# fetch price
sub fetch_price
{
    my $shop = shift;
    my $url  = shift;
    my $price;

    return 'n/a' unless ( $url =~ m#^https?://# );

    my @page = fetch_url($url);

    if ( $shop eq "alza" )
    {
        # parsing alfacomp.cz
        # my @ceny = grep( m#<strong>Va.e cena v.etn. DPH: </strong>#, @page );
        my @ceny = grep( m#<td class="c2"><span>#, @page );
        @ceny = $ceny[1];
        #if ( scalar( @ceny ) == 1 ) {
            # if ( $ceny[0] =~ m#<td class="price"><strong>(.*)K.</strong># ) {
            if ( $ceny[0] =~ m#<td class="c2"><span>(.*),-</span></td># ) {
                $price = $1;
            }
        #}
    }
    elsif ( $shop eq "mironet" )
    {
        # parsing mironet.cz
        my @ceny = grep( /<span itemprop=\"price\">/, @page );
        my $str = $ceny[0];
        $str =~ s/<span itemprop=\"price\">//;
        $str =~ s/<\/span>,-<br \/><span class=\"sdph\">s DPH<\/span>//;            
        $str =~ s/[\s]{1,}//g;
        $str = decode("UTF-8", $str);
        $str =~ s/[�]{1}//g;
        #$str =~ s/[\x{31}\x{39}]{1}//g;
        $str = int($str);
        $price = sprintf("%d", $str);
    }
    elsif ( $shop eq "czc" )
    {
        # parsing czc.cz
        my @ceny = grep( /title=\"cena bez DPH: /, @page );
        #print Dumper( @ceny );
        #if ( scalar( @ceny ) == 1 ) {
            #if ( $ceny[0] =~ m#cena bez DPH: ([0-9]){1}([0-9]){1,}# ) {
            my $str = $ceny[0];
            #$str =~ /&nbsp/([0-9]){1,}([\s]){1,}([0-9]){3}/;
            $str =~ s/&nbsp;/ /g;
            $str =~ s/title=\"cena bez DPH: //g;
            $str =~ s/[\s]{1,}//g;
            $str =~ s/K(.*)//;
            $str =~ s/[^0-9]//g;
            #$str = decode("utf8", $str);
            #$price = sprintf("%d", $str);
            #$str =~ /([0-9]){1,}/;
            #if ( $ceny[0] =~ m#(\d+\[\t]\d+)# {
            $price = int(int($str) + int($str)*0.21);
            #}
        #}
    }

    return 'error' unless $price;

    $price =~ s/[^0-9]//g;

    return $price;
}

die("Missing argument or argument not a file\n") unless ( defined( $ARGV[0] ) and ( -f $ARGV[0] ) );

my $items_list = parse_ini_file($ARGV[0]);

foreach my $item ( keys ( %{$items_list} ) ) {
    foreach my $shop ( keys( %{$items_list->{"$item"}} ) ) {
        my $price = fetch_price( $shop, $items_list->{"$item"}->{"$shop"} );
        print "$item from $shop ... $price\n";
        $items_list->{"$item"}->{"$shop"} = $price;
    }
}

# TODO: detect e-shop from $items_list
if ( $fancy_output ) {
    # header
    my $format = "%40s %10s %10s %10s\n";
    printf($format,"ITEM","ALZA","CZC","MIRONET"); # TODO: add "ALFA"
    foreach my $item ( keys ( %{$items_list} ) ) {
        printf($format,$item,
            $items_list->{"$item"}->{"alza"},
            $items_list->{"$item"}->{"czc"},
            $items_list->{"$item"}->{"mironet"},
        )
    }
} else {
    print Dumper( $items_list );
}
# vim:foldmethod=marker:ts=4:sw=4:noexpandtab