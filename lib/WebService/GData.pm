package WebService::GData;
use 5.008008;
use strict;
use warnings;
use Data::Dumper;
use overload '""'=>"__to_string";

our $VERSION  = 0.01_01;

	sub import {
   		strict->import;
   		warnings->import;
	}

	sub new {
		my $package=shift;
		my $this={};
		bless $this, $package;
		$this->__init(@_);
		return $this;
	}

	sub __init {
		my ($this,%params) = @_;
		while(my ($prop,$val)=each %params){
			$this->{$prop}=$val;
		}
	}

	sub __to_string {
		return Dumper(shift);
	}

	sub install_in_package {
		my($subnames,$callback)=@_;

	    my $package = caller;
	    return if($package eq 'main'); #never import into main
		#install
		no strict 'refs';
		foreach my $sub (@$subnames) {
			*{$package.'::'.$sub} = &$callback($sub);
		}
		
	}


"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData - represent a base GData object.

=head1 VERSION

0.01

=head1 SYNOPSIS

	package WebService::MyService;
	use WebService::GData;#strict/warnings turned on
	use base 'WebService::GData';

	#this is the base implementation of the __init method in WebService::GData
	#it is call when new is used
	#you should overwrite it if necessary.
	sub __init {
		my ($this,%params) = @_;
		while(my ($prop,$val)=each %params){
			$this->{$prop}=$val;
		}
		return $this;
	}

	sub name {
		my $this = shift;
		return $this->{name};
	}

	1;

    
    use WebService::MyService; 

    #create an object
   	my $object = new WebService::MyService(name=>'test');

	$object->name;#test

	#overloaded string will dump the object with Data::Dumper;
	print $object;#$VAR1 = bless( { 'name' => 'test' }, 'WebService::MyService' );


=head1 DESCRIPTION

This package does not do much.You should inherit and extends it. 

It just offers a basic hashed based object creation via the word new. 

All sub classes should be hash based. If you want to pock into the instance, it's easy 

but everything that is not documented should considered private to the API. 

If you play around with undocumented properties/methods and that it changes,

upgrading to the new version with all the extra new killer features will be very hard to do. 

so...

dont.

Mostly, you will want to look the abstract classes from which services extend their feature:

- WebService::GData::Base

- WebService::GData::ClientLogin

- WebService::GData::Error

- WebService::GData::Query

- WebService::GData::Feed

A service in progress:

- WebService::GData::YouTube



=head1  SUBROUTINE


=head2 new

=over

Takes an hash which keys will be attached to the instance.


=head1  CONFIGURATION AND ENVIRONMENT

none


=head1  DEPENDENCIES

none

=head1  INCOMPATIBILITIES

none

=head1 BUGS AND LIMITATIONS

If you do me the favor to _use_ this module and find a bug, please email me
i will try to do my best to fix it (patches welcome)!

=head1 AUTHOR

shiriru E<lt>shiriru0111[arobas]hotmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
