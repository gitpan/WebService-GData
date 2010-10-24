package WebService::GData::YouTube::Node::Statistics;
use WebService::GData::YouTube::Node;

set_xml_meta(
  attributes=>[qw(viewCount videoWatchCount subscriberCount lastWebAccess favoriteCount totalUploadViews)],
  is_parent =>0
);


1;