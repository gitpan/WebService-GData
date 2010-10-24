package WebService::GData::Node::GD;

use WebService::GData::Node;

sub import {
    my $package = caller;
    return if($package->isa(__PACKAGE__)||$package eq 'main'|| $package!~m/GD::/);
    WebService::GData::Node->import($package);
{
	no strict 'refs';
	unshift @{$package.'::ISA'},__PACKAGE__;
}
}

sub root_name {'gd'};


1;