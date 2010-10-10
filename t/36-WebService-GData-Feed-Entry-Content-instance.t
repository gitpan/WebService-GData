use Test::More tests => 4;
use WebService::GData::Feed::Entry::Content;

my $content = new WebService::GData::Feed::Entry::Content({
    src => "http://www.youtube.com/v/qW...YvHqLE",
    type   => "application/x-shockwave-flash"
});
    

ok(ref($content) eq 'WebService::GData::Feed::Entry::Content','$content is a WebService::GData::Feed::Entry::Content instance.');
ok($content->src eq 'http://www.youtube.com/v/qW...YvHqLE','$content->src is properly set.');
ok($content->type eq 'application/x-shockwave-flash','$content->type is properly set.');

eval {
$content = new WebService::GData::Feed::Entry::Content();
};
my $error =$@;    

ok($error->code() eq 'invalid_parameter_type','WebService::GData::Feed::Entry::Content throws an error if the parameter is wrong.');


