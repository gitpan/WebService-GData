package WebService::GData::YouTube::YT::Media::Content;
use base 'WebService::GData::Node::Media::Content';
use WebService::GData::YouTube::YT();


sub attributes {
  return \(@{WebService::GData::Node::Media::Content->attributes},'yt:format');
}

sub extra_namespaces {
    return {WebService::GData::YouTube::YT->root_name=>WebService::GData::YouTube::YT->namespace_uri};
}



1;
