package WebService::GData::Node::Media::Content;
use WebService::GData::Node::Media;

set_xml_meta(
    attributes=>[qw(url type medium isDefault expression duration),'yt:format'],
    is_parent =>0
);



1;
