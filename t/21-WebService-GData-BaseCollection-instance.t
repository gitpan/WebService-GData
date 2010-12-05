use Test::More tests => 4;
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

