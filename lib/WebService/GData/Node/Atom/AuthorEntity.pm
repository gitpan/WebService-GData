package WebService::GData::Node::Atom::AuthorEntity;
use base 'WebService::GData::Node::AbstractEntity';
use WebService::GData::Node::Atom::Author();
use WebService::GData::Node::Atom::Uri();
use WebService::GData::Node::Atom::Name();


our $VERSION = 0.01_01;

sub __init {
	my ($this,$params) = @_;

	$this->_entity(new WebService::GData::Node::Atom::Author());
	$this->{_name}   = new WebService::GData::Node::Atom::Name($params->{name});
	$this->{_uri}    = new WebService::GData::Node::Atom::Uri ($params->{uri});
	$this->_entity->child($this->{_name})->child($this->{_uri});
}



1;
