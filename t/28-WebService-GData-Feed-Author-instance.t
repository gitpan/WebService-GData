use Test::More tests => 4;
use WebService::GData::Feed::Author;

my $author = new WebService::GData::Feed::Author({name=>{'$t'=>'doe'},uri=>{'$t'=>'http://www.youtube.com'}});
    

ok(ref($author) eq 'WebService::GData::Feed::Author','$author is a WebService::GData::Feed::Author instance.');
ok($author->name eq 'doe','$author->name is properly set.');
ok($author->uri eq 'http://www.youtube.com','$author->uri is properly set.');

eval {
$author = new WebService::GData::Feed::Author();
};
my $error =$@;    

ok($error->code() eq 'invalid_parameter_type','WebService::GData::Feed::Author throws an error if the parameter is wrong.');


