use Test::More tests => 5;
use WebService::GData::Feed::Link;

my $link = new WebService::GData::Feed::Link({
        "rel" => "alternate",
        "type"=> "text/html",
        "href"=> "http://www.youtube.com"
       });
    

ok(ref($link) eq 'WebService::GData::Feed::Link','$link is a WebService::GData::Feed::Link instance.');
ok($link->rel eq 'alternate','$link->rel is properly set.');
ok($link->type eq 'text/html','$link->type is properly set.');
ok($link->href eq 'http://www.youtube.com','$link->href is properly set.');

eval {
$link = new WebService::GData::Feed::Link();
};
my $error =$@;    

ok($error->code() eq 'invalid_parameter_type','WebService::GData::Feed::Link throws an error if the parameter is wrong.');


