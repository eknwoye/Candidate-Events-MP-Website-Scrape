#!/usr/bin/env perl
#
#
# Project Challenge: Scrape the 'text' and 'events pages' of MPs websites and create a navigable database containing that information so that it can be subject to analysis. 
# Useful Links: https://www.theyworkforyou.com/mps/ 
# https://members.parliament.uk/constituencies 
#
#
# Here's a full Perl 5.x script that:

# Scrapes MP data from:

# 1. https://www.theyworkforyou.com/mps/


# 2. https://members.parliament.uk/constituencies



# Visits each MP’s profile/linked page to collect and analyze textual data.

# Uses regex to extract insights (e.g., personality, ideology, policy themes).

# Stores results in a CSV (ukmpprofile2.csv).

# Provides both:

# A CLI search interface.

# A Mojolicious web viewer for search/display.
#
#
# DISCLAIMER: Where as the Application code script and tool is intended to facilitate research, by authorised and approved parties, pursuant to the ideals of libertarian democracy in the UK, by Campaign Lab membership. And where as deemed to be in the public domain, content subject-matter and generated results can be assumed sensitive and thus confidential. Therefore illicit and unauthorised usage outside these terms, is hereby not implied pursuant to requisite UK Data Protection legislation and the wider GDPR enactments within the EU. Usage without the consent of the author, is also NOT implied.
#
# CODE REVISION & AUTHOR: Ejimofor Nwoye, Campaign Lab, Newspeak House, London, England @ 14/07/2025.
#


use strict;
use warnings;
use utf8;
use Mojo::UserAgent;
use Mojo::DOM;
use Text::CSV;
use Encode;
use Getopt::Long;
use Mojolicious::Lite;

# Setup
my $ua = Mojo::UserAgent->new;
my $csv_file = 'ukmpprofile2.csv';
my @results;

# Regex dictionary for thematic extraction
my %themes = (
    "Personality and Social Identity" => qr/\b(confident|charismatic|introverted|leader|background|community|identity|grassroots)\b/i,
    "Ideology and Thought"            => qr/\b(conservative|liberal|socialist|centrist|philosophy|ideology|left-wing|right-wing|marxist|tory|labour)\b/i,
    "Events and Agenda"               => qr/\b(event|meeting|agenda|timetable|schedule|calendar|priority|visit|launch)\b/i,
    "Asylum and Immigration"          => qr/\b(immigration|asylum|refugee|border|visa|deportation|migrant)\b/i,
    "Crime and Policing"              => qr/\b(police|crime|criminal|justice|sentencing|violence|security)\b/i,
    "Economy and Living"              => qr/\b(economy|finance|cost of living|tax|council tax|budget|inflation)\b/i,
    "EU and Devolution"              => qr/\b(Brexit|EU|European Union|independence|devolution|referendum|Scotland|Wales)\b/i,
    "Welfare and Health"             => qr/\b(NHS|healthcare|welfare|benefits|public health|mental health|hospital|GP)\b/i,
    "Transport"                      => qr/\b(transport|rail|bus|infrastructure|roads|traffic|cycling|travel)\b/i,
);

# Get all MP links from TheyWorkForYou
sub scrape_mps {
    my $url = 'https://www.theyworkforyou.com/mps/';
    my $dom = $ua->get($url)->result->dom;

    for my $a ($dom->find('ul.listing li a')->each) {
        my $mp_url  = $a->{href};
        my $mp_name = $a->text;
        next unless $mp_url =~ m{^/mp/};

        my $full_url = "https://www.theyworkforyou.com$mp_url";
        my $mp_text  = $ua->get($full_url)->result->body;

        my %profile = analyze_text($mp_name, $full_url, $mp_text);
        push @results, \%profile;
    }
}

# Analyze content using regex patterns
sub analyze_text {
    my ($name, $url, $text) = @_;
    my %matches = (Name => $name, URL => $url);

    for my $theme (keys %themes) {
        $matches{$theme} = ($text =~ $themes{$theme}) ? "Yes" : "";
    }

    return %matches;
}

# Save to CSV
sub save_to_csv {
    open my $fh, ">:encoding(utf8)", $csv_file or die "Cannot write CSV: $!";
    my $csv = Text::CSV->new({ binary => 1, eol => $/ });

    my @columns = qw(Name URL)
      . sort grep { $_ ne 'Name' && $_ ne 'URL' } keys %{ $results[0] };
    $csv->print($fh, \@columns);

    foreach my $row (@results) {
        $csv->print($fh, [ map { $row->{$_} // '' } @columns ]);
    }
    close $fh;
    print "Saved results to $csv_file\n";
}

# CLI Search Interface
sub cli_search {
    my $keyword = '';
    GetOptions("search=s" => \$keyword);
    return unless $keyword;

    open my $fh, "<:encoding(utf8)", $csv_file or die "CSV open failed: $!";
    my $csv = Text::CSV->new({ binary => 1 });
    my $headers = $csv->getline($fh);

    while (my $row = $csv->getline($fh)) {
        my %row_data;
        @row_data{@$headers} = @$row;
        if (grep { /$keyword/i } @$row) {
            print join(" | ", @$row), "\n";
        }
    }
    close $fh;
}

# Mojolicious Web Viewer
any ['GET', 'POST'] => '/' => sub {
    my $c = shift;
    my $q = $c->param('query') || '';
    my @matches;

    if ($q) {
        open my $fh, "<:encoding(utf8)", $csv_file or die "CSV open failed";
        my $csv = Text::CSV->new({ binary => 1 });
        my $headers = $csv->getline($fh);

        while (my $row = $csv->getline($fh)) {
            if (grep { /$q/i } @$row) {
                push @matches, { map { $headers->[$_] => $row->[$_] } 0..$#$row };
            }
        }
        close $fh;
    }

    $c->stash(matches => \@matches, query => $q);
    $c->render(template => 'search');
};

app->start('daemon', '-l', 'http://*:3000') if @ARGV && $ARGV[0] eq 'web';

# Main
unless (@ARGV) {
    scrape_mps();
    save_to_csv();
}
elsif ($ARGV[0] eq 'cli') {
    cli_search();
}

__DATA__

@@ search.html.ep
% layout 'default';
% title 'UK MP Profile Search';
<h1>Search MP Profiles</h1>
<form method="POST">
  <input type="text" name="query" placeholder="Search term" value="<%= $query %>">
  <button type="submit">Search</button>
</form>

% if (@$matches) {
  <table border="1">
    <tr><%= join '', map { "<th>$_</th>" } keys %{$matches->[0]} %></tr>
    % foreach my $row (@$matches) {
      <tr><%= join '', map { "<td>$row->{$_}</td>" } keys %$row %></tr>
    % }
  </table>
% } elsif ($query) {
  <p>No results found for "<%= $query %>"</p>
% }

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

