package WebService::GData::Node::Atom::AtomEntity;
use base 'WebService::GData::Node::AbstractEntity';

use WebService::GData::Node::Atom::AuthorEntity();
use WebService::GData::Node::Atom::Category();
use WebService::GData::Node::Atom::Id();
use WebService::GData::Node::Atom::Link();
use WebService::GData::Node::Atom::Title();
use WebService::GData::Node::Atom::Updated();
use WebService::GData::Collection;

our $VERSION = 0.01_01;

sub __init {
	my ($this,$params) = @_;
	
    $this->{_feed} = {};

    if ( ref($params) eq 'HASH' ) {
        $this->{_feed} = $params->{feed} || $params;
    }
	
    $this->__set_tag('WebService::GData::Node::Atom::','AuthorEntity','author');
    $this->__init_tags('WebService::GData::Node::Atom::',(qw(category id link title updated)));

}

sub set_children {
    my $this = shift;
    
    $this->_entity->child($this->{'_'.$_}) foreach((qw(author category id link title updated)));
}

private __set_tag => sub {
   my ($this,$package,$class,$node)=@_;

   if ( ref( $this->{_feed}->{$node} ) eq 'ARRAY' ) {
        my $tags     = $this->{_feed}->{$node};
        my @instances = ();
        my $class    = $package . "\u$class";
        foreach my $tag (@$tags) {
            push @instances, $class->new($tag);
        }
        $this->{'_'.$node} = new WebService::GData::Collection(\@instances);
    }
    else {
         my $class = $package . "\u$class"; 
         $this->{'_'.$node}=  $class->new($this->{_feed}->{$node}); 
    }   
};

private __init_tags => sub {
    my ( $this, $package,@nodes ) = @_;
    foreach my $node (@nodes) {  
        $this->__set_tag($package,"\u$node",$node);
    }
};

sub links {
    my $this = shift;
    $this->link;
}

sub get_link {
    my ($this,$search) = @_;
    my $link = $this->link->rel($search)->[0];
    return $link->href if($link);
}

"The earth is blue like an orange.";
