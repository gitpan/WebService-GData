use Test::More tests => 6;
use WebService::GData::BaseCollection();
my $collection = new WebService::GData::BaseCollection(undef,undef);


my $nodes = [{text=>'i am a node'},{text=>'i am also node'}];
push @$collection, $nodes->[0];

push @$collection, $nodes->[1];


my $i=0;
foreach my $elm (@$collection){
     ok($elm->{text} eq $nodes->[$i]->{text});
     ok($elm->{text} eq $nodes->[$i]->{text});
     $i++;
}

$collection = new WebService::GData::BaseCollection(undef,sub { my $val = shift; ref $val ne 'HASH' ? {text=>'dummy'}:$val });

$nodes = [{text=>'i am a node'},1];

push @$collection, $nodes->[0];

push @$collection, $nodes->[1];

ok(ref $collection->[1] eq 'HASH','the set method changed the value');
ok($collection->[1]->{text} eq 'dummy','the new value contains the proper text');