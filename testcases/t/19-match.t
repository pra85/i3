#!perl
# vim:ts=4:sw=4:expandtab
#
# Tests all kinds of matching methods
#
use i3test;
use X11::XCB qw(:all);

my $tmp = fresh_workspace;

ok(@{get_ws_content($tmp)} == 0, 'no containers yet');

# Open a new window
my $x = X11::XCB::Connection->new;
my $window = $x->root->create_child(
    class => WINDOW_CLASS_INPUT_OUTPUT,
    rect => [ 0, 0, 30, 30 ],
    background_color => '#C0C0C0',
);

$window->map;
# give it some time to be picked up by the window manager
# TODO: better check for $window->mapped or something like that?
# maybe we can even wait for getting mapped?
my $c = 0;
while (@{get_ws_content($tmp)} == 0 and $c++ < 5) {
    sleep 0.25;
}
my $content = get_ws_content($tmp);
ok(@{$content} == 1, 'window mapped');
my $win = $content->[0];

######################################################################
# first test that matches which should not match this window really do
# not match it
######################################################################
# TODO: use PCRE expressions
# TODO: specify more match types
cmd q|[class="*"] kill|;
cmd q|[con_id="99999"] kill|;

$content = get_ws_content($tmp);
ok(@{$content} == 1, 'window still there');

# now kill the window
cmd 'nop now killing the window';
my $id = $win->{id};
cmd qq|[con_id="$id"] kill|;

# give i3 some time to pick up the UnmapNotify event
sleep 0.25;

cmd 'nop checking if its gone';
$content = get_ws_content($tmp);
ok(@{$content} == 0, 'window killed');

# TODO: same test, but with pcre expressions

done_testing;