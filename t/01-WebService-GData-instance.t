use Test::More tests => 3;
use WebService::GData;

my $gdata = new WebService::GData(firstname=>'doe',lastname=>'john');

ok(ref($gdata) eq 'WebService::GData','$gdata is a WebService::GData instance.');
ok($gdata->{firstname} eq 'doe','$gdata->{firstname} is properly set.');
ok($gdata->{lastname} eq 'john','$gdata->{lastname} is properly set.');

