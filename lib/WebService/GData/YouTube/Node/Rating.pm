package WebService::GData::YouTube::Node::Rating;
use WebService::GData::YouTube::Node;

set_xml_meta(
    attributes=>[qw(numLikes numDislikes value)],
    is_parent=>0,
);

1;