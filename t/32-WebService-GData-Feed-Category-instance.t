use Test::More tests => 5;
use WebService::GData::Feed::Category;

my $category = new WebService::GData::Feed::Category({
    scheme => "http://schemas.google.com/g/2005#kind",
    term   => "http://gdata.youtube.com/schemas/2007#video",
    label  => 'Shows'
});
    

ok(ref($category) eq 'WebService::GData::Feed::Category','$category is a WebService::GData::Feed::Category instance.');
ok($category->scheme eq 'http://schemas.google.com/g/2005#kind','$category->scheme is properly set.');
ok($category->term eq 'http://gdata.youtube.com/schemas/2007#video','$category->term is properly set.');
ok($category->label eq 'Shows','$category->label is properly set.');

eval {
$category = new WebService::GData::Feed::Category();
};
my $error =$@;    

ok($error->code() eq 'invalid_parameter_type','WebService::GData::Feed::Link throws an error if the parameter is wrong.');


