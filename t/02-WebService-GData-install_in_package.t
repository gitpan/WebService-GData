use Test::More tests => 7;
use WebService::GData;
use t::MyWeb;
use Data::Dumper;

my $web = new MyWeb(firstname=>'doe',lastname=>'john');

ok(MyWeb->isa('WebService::GData'),'MyWeb package is a child of WebService::GData.');
ok($web->isa('WebService::GData'),'$web instance is a child of WebService::GData.');
ok(ref($web) eq 'MyWeb','$web is a MyWeb instance.');
ok($web->firstname eq 'doe','$web->firstname is properly set.');
ok($web->{extra} ==1,'__init extension works.');
$web->firstname('marley');
ok($web->firstname eq 'marley','$web->firstname is properly reset.');
ok("$web" eq Dumper($web),'string overload is working fine.');
