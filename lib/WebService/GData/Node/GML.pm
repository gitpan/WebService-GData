package WebService::GData::Node::GML;

use WebService::GData::Node;

sub import {
    my $package = caller;
    return if($package->isa(__PACKAGE__)||$package eq 'main'||$package!~m/GML::/);
    WebService::GData::Node->import($package);
{
	no strict 'refs';
	unshift @{$package.'::ISA'},__PACKAGE__;
	
}
}

sub root_name {'gml'};


1;