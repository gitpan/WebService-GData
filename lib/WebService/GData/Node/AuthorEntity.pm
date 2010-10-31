package WebService::GData::Node::AuthorEntity;
use base 'WebService::GData::Node::AbstractEntity';
use WebService::GData::Node::Author();
use WebService::GData::Node::Uri();
use WebService::GData::Node::Name();


our $VERSION = 0.01_01;

sub __init {
	my ($this,$params) = @_;

	$this->_entity(new WebService::GData::Node::Author());
	$this->{_name}   = new WebService::GData::Node::Name($params->{name});
	$this->{_uri}    = new WebService::GData::Node::Uri ($params->{uri});
	$this->_entity->child($this->{_name})->child($this->{_uri});
}



1;
