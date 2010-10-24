package WebService::GData::Node::GD::Rating;
use WebService::GData::Node::GD;

set_xml_meta(
   attributes=>[qw(min max numRaters average value)],
   is_parent=>0
);

1;
