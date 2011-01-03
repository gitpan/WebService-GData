package WebService::GData::YouTube::YT::Media::Credit;
use base 'WebService::GData::Node::Media::Credit';
use WebService::GData::YouTube::YT();


sub attributes {
  return \(@{WebService::GData::Node::Media::Credit->attributes},'yt:type');
}

sub extra_namespaces {
    return {WebService::GData::YouTube::YT->root_name=>WebService::GData::YouTube::YT->namespace_uri};
}



1;
