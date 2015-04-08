#!/usr/bin/env perl
use Modern::Perl;
use Config::Tiny;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

#
# Simple script for sending PushBullet new data for
# the universal Copy/Paste feature.
# I will likely try to combine scripts in the future.
#
# Create an account at  https://www.pushbullet.com/
# Look at your account settings for your Access Token
# Save the token to ~/.pushbulletrc
#   apiKey=<ACCESS KEY>
#
# Use the program by piping data to the script
# that you want available for pasting.

# Example:
#   echo "text to copy" | universalCopy.pl
#
# I am trying this out with tmux right now.
# In tmux.conf
#  bind C-c run "tmux save-buffer - | ~/bin/universalCopy.pl"
#
# Once something is highlighted use the tmux key with Ctrl-C
# the data in the copy buffer will be pushed out.
#

my $server = 'https://api.pushbullet.com/v2/ephemerals';

my $CONFIG_FILE = "$ENV{HOME}/.pushbulletrc";

my $conf = Config::Tiny->read($CONFIG_FILE)
    or die "Failed to open '$CONFIG_FILE' file to get API key: " . Config::Tiny->errstr;

my $apiKey = $conf->{_}{apiKey}
    or die "Unable to locate API Key in '$CONFIG_FILE' file.";

my $body;
while (<>) {
    $body .= $_;
}

if ($body eq '') {
    die 'No data to copy!';
}

my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );

my $req = HTTP::Request->new(POST => $server);
$req->header('content-type' => 'application/json');
$req->header('Authorization' => "Bearer $apiKey");

my $data = {
            type => 'push',
            push => {
                     type => 'clip',
                     body => $body,
                    },
           };
$req->content( encode_json $data );

my $resp = $ua->request($req);

#TODO - Send output to log file, or add an option for it
if ($resp->is_success) {
    my $message = decode_json $resp->decoded_content;
    say 'Received reply: ' . Dumper($message);
} else {
    say 'HTTP POST error code: ' . $resp->code;
    say 'HTTP POST error message: ' . $resp->message;
    say 'Status Line: ' . $resp->status_line;
}
