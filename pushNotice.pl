#!/usr/bin/env perl
use Modern::Perl;
use Config::Tiny;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

#
# Simple script for sending PushBullet Notes
# Create an account at  https://www.pushbullet.com/
# Look at your account settings for your Access Token
# Save the token to ~/.pushbulletrc
#   apiKey=<ACCESS KEY>
#
# Use the program by piping in text to the script
# that you want in the body of the notification.
# Set the title by specifying it as the first
# argument after the script.
# Example:
#   echo "Message Body" | pushNotice.pl "Notice Subject"
#

#TODO - Add support for other API calls
my $server = 'https://api.pushbullet.com/v2/pushes';

my $CONFIG_FILE = "$ENV{HOME}/.pushbulletrc";

my $conf = Config::Tiny->read($CONFIG_FILE)
    or die "Failed to open '$CONFIG_FILE' file to get API key: " . Config::Tiny->errstr;

my $apiKey = $conf->{_}{apiKey}
    or die "Unable to locate API Key in '$CONFIG_FILE' file.";

my $title = shift @ARGV || 'Notice!';
my $body;
while (<>) {
    $body .= $_;
}

if ($body eq '') {
    warn 'No body included in notice!';
}

my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );

my $req = HTTP::Request->new(POST => $server);
$req->header('content-type' => 'application/json');
$req->header('Authorization' => "Bearer $apiKey");

#TODO - Add option for other links and files
my $postData = {
                 type  => 'note',
                 title => $title,
                 body  => $body,
               };
$req->content( encode_json $postData );

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
