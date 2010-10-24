use Test::More tests => 5;
use WebService::GData::Node::AuthorEntity();

my $author = new WebService::GData::Node::AuthorEntity({name=>{'$t'=>'doe'},uri=>{'$t'=>'http://www.youtube.com'}});
    

ok(ref($author) eq 'WebService::GData::Node::AuthorEntity','$author is a WebService::GData::Node::AuthorEntity instance.');
ok($author->name eq 'doe','$author->name is properly set.');
ok($author->uri eq 'http://www.youtube.com','$author->uri is properly set.');

$author->uri('caramba');

ok($author->uri eq 'caramba','$author->uri is properly re setted.');
ok($author->serialize eq '<author><name>doe</name><uri>caramba</uri></author>','AuthorEntity is properly serialized');

