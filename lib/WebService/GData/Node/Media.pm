package WebService::GData::Node::Media;

use WebService::GData::Node;

sub import {
    my $package = caller;
    return if($package->isa(__PACKAGE__)||$package eq 'main'||$package!~m/Media::/);
    WebService::GData::Node->import($package);
{
	no strict 'refs';
	unshift @{$package.'::ISA'},__PACKAGE__;
	
}
}

sub root_name {'media'};


1;