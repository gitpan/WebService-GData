package WebService::GData::YouTube::Node;

use WebService::GData::Node;

our $VERSION = 0.01_01;

sub import {
    my $package = caller;
    return if($package->isa(__PACKAGE__)||$package eq 'main');
    WebService::GData::Node->import($package);
{
	no strict 'refs';
	unshift @{$package.'::ISA'},__PACKAGE__;
	
}
}

sub root_name {'yt'};


1;