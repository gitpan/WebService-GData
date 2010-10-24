use Test::More tests => 4;
use WebService::GData::Node::Link;

my $link = new WebService::GData::Node::Link({
        "rel" => "alternate",
        "type"=> "text/html",
        "href"=> "http://www.youtube.com"
       });
    

ok(ref($link) eq 'WebService::GData::Node::Link','$link is a WebService::GData::Node::Link instance.');
ok($link->rel eq 'alternate','$link->rel is properly set.');
ok($link->type eq 'text/html','$link->type is properly set.');
ok($link->href eq 'http://www.youtube.com','$link->href is properly set.');


