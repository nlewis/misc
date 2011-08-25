#!/usr/bin/perl
use strict;
use warnings;

# generates a simple page which displays and ranks l4d2 players' win percentages
# for now only works if player's steam profile is public (even if you're friends with them)

use CGI;
use LWP::Simple;
use Data::Dumper;

my $cgi = CGI->new;

print $cgi->header;
print $cgi->start_html('l4d2 score thingie');

# LIST_OF_ASSHOLES.JPG
my $player_names = $cgi->param('players') || 'Kidane, djnite, jizmakdagusha, catawompus, frostyends';
my @players = map { { 'name' => $_ } } split(',', $player_names);

# length of longest name for text formatting purposes later
my $longest = (sort {$a <=> $b} map { length($_->{'name'}) } @players)[-1];

foreach my $player (@players) {

    # leading or trailing whitespace breaks the request
    $player->{'name'} =~ s/^\s+//;
    $player->{'name'} =~ s/\s+$//;

    # requires player has set up their steam nickname, if they just have an ID the URL is different ;_;
    my $content = get("http://steamcommunity.com/id/" . $player->{'name'} . "/stats/L4D2?tab=stats&subtab=versus");

    # it's ok if these are undefined, will just show up as 0 / 0 (0%)
    if ($content =~ m/<div id="winlosstxtleft">(\d+)% won \((\d+) games\)<\/div>(\d+)% lost \((\d+) games\)/) {
        $player->{'won_percent'} = $1;
        $player->{'won_total'}   = $2;
        $player->{'loss_total'}  = $4;
    }

}

#NOW WE'RE COOKING WITH FIRE
print "<pre>";

# sorted by won_percent (descending) using schwartzian transform
foreach my $player (map { $_->[1] } sort { $b->[0] <=> $a->[0] } map { [ $_->{'won_percent'}, $_ ] } @players) {

    # pad list by spaces equal to length of longest player name
    printf("%${longest}s: %d / %d games (%d%%)\n", 
            $player->{'name'}, $player->{'won_total'}, $player->{'loss_total'}, $player->{'won_percent'});
}

# sorry i'm really bad at html
print "</pre><br>";
print "<p>Players are ordered by win percentage. Don't be jelly.<br>";
print "Enter comma-separated list of player IDs below. Doesn't work if user's profile is private.";
print '<p><form action="http://minecraft.nickforsale.com/l4d2/index.pl" method=get>';
print "<input type=\"text\" name=\"players\" size=\"80\" value=\"" . join(',', map { $_->{'name'} } @players) . "\">";
print '<input type=submit value="gimme"';
print '</form>';
print '<form action="http://minecraft.nickforsale.com/l4d2/index.pl" method="link">';
print '<input type="submit" value="default">';
print '</form>';
print '<p>TODO: <br>- historical data (daily?)<br>';
print '- graphs and shit<br>';
print '- steam id => nickname mapping<br>';
print '- handle steam profile id in addition to username<br>';
print '- whatever, i ain\'t even mad<br>';

print $cgi->end_html;
