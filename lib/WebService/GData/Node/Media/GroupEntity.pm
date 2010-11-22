package WebService::GData::Node::Media::GroupEntity;
use base 'WebService::GData::Node::AbstractEntity';
use WebService::GData::Node::Media::Group();
use WebService::GData::Node::Media::Category();
use WebService::GData::Node::Media::Content();
use WebService::GData::Node::Media::Credit();
use WebService::GData::Node::Media::Description();
use WebService::GData::Node::Media::Keywords();
use WebService::GData::Node::Media::Player();
use WebService::GData::Node::Media::Title();
use WebService::GData::Node::PointEntity();
use WebService::GData::Collection;

our $VERSION = 0.01_01;
my $serializable =[qw(category description keywords title)];
my $nodes        =[qw(credit player content)];

sub __init {
	my ($this,$params) = @_;

	$this->_entity(new WebService::GData::Node::Media::Group());
	
    foreach my $node (@$nodes){
        $this->{'_'.$node}= $this->__node_factory($node,$params);
    }
    foreach my $node (@$serializable){
        $this->{'_'.$node}= $this->__node_factory($node,$params);
        $this->_entity->child($this->{'_'.$node});
    }
}

sub __node_factory {
    my($this,$node,$params)=@_;
    my $class = 'WebService::GData::Node::Media::'."\u$node";
    my $data  = $params->{'media$'.$node};
    if(ref($data) eq 'ARRAY') {
        my @collection=();
        foreach my $d (@$data){
            push @collection, $class->new($d);
        }
        return new WebService::GData::Collection(\@collection);
    }
    return $class->new($data);
}



1;

