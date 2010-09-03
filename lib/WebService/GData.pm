package WebService::GData;
use 5.008008;
use strict;
use warnings;
use Data::Dumper;
use overload '""'=>"__to_string";

our $VERSION  = 0.01_04;

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
		my($subnames,$callback,$package)=@_;

	    $package = $package || caller;
	    return if($package eq 'main'); #never import into main
		#install
		no strict 'refs';
		no warnings 'redefine';
		foreach my $sub (@$subnames) {
			*{$package.'::'.$sub} = &$callback($sub);
		}
		
	}


"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData - represent a base GData object.

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

    WebService::GData::install_in_package([qw(firstname lastname age gender)],sub {
            my $func = shift;
            return sub {
                my $this = shift;
                return $this->{$func};
            }
    });

    #the above is equal to writing these simple getters:

    #sub firstname {
    #    my $this = shift;
    #    return $this->{firstname};
    #}

    #sub lastname {
    #    my $this = shift;
    #    return $this->{lastname};
    #}

    #sub age {
    #    my $this = shift;
    #    return $this->{age};
    #}  

    #sub gender {
    #    my $this = shift;
    #    return $this->{gender};
    #}  

    1;

    
    use WebService::MyService; 

    #create an object
       my $object = new WebService::MyService(name=>'test');

    $object->name;#test

    #overloaded string will dump the object with Data::Dumper;
    print $object;#$VAR1 = bless( { 'name' => 'test' }, 'WebService::MyService' );


=head1 DESCRIPTION

This package does not do much.It is a blueprint that you should inherit and extend. 

It offers a basic hashed based object creation via the word new. 

All sub classes should be hash based. If you want to pock into the instance, it's easy 

but everything that is not documented should be considered private. 

If you play around with undocumented properties/methods and that it changes,

upgrading to the new version with all the extra new killer features will be very hard to do. 

so...

dont.

Mostly, you will want to look at the following abstract classes from which services extend their feature:

=over

=item L<WebService::GData::Base>

Implements the base get/post/insert/update/delete methods

=item L<WebService::GData::ClientLogin>

Implements the ClientLogin authorization system

=item L<WebService::GData::Error>

Represents a Google data protocol Error

=item L<WebService::GData::Query>

Implements the basic query parameters and create a query string.

=item L<WebService::GData::Feed>

Represents the basic tags found in a Atom Feed (JSON format).

=back

A service in progress:

=over

=item L<WebService::GData::YouTube>

Implements some of the YouTube API functionalities.

=back

=head2  CONSTRUCTOR

=head3 new


Takes an hash which keys will be attached to the instance.

You can also use install_in_package() to create setters/getters for these parameters.

I<Parameters>:

=over

=item C<parameters:RefHash>

=back

I<Return>:

=over

=item C<object:RefHash>

=back


Example:
    
    use WebService::GData; 

    #create an object
    my $object = new WebService::GData(firstname=>'doe',lastname=>'john',age=>'123');

    $object->{firstname};#doe

=head2 METHODS

=head3 __init

This method is called by the constructor new().

This function receives the parameters set in new() and by default assign the key/values pairs to the instance.

You should overwrite it and add your own logic.

=head3 __to_string

This method overloads the stringification quotes to display a dump of the object by using Data::Dumper. 

You should overwrite it should you need to create a specific output.

=head2  SUB

=head3 install_in_package

Install in the package the methods/subs specified. 
Mostly use to avoid writting boiler plate getter/setter methods.

I<Parameters>:

=over

=item C<subnames:ArrayRef>

The array reference should list the name of the methods you want to install in the package.

=item C<callback:Sub>

The callback is a _sub_ that will receive the name of the function.

This callback should itself send back a function.

=item C<package_name:Scalar> (optional)

You can add functions at distance by specifying an other module.

=back

I<Return>:

=over

=item C<void>

=back

Example:

    package Basic::User;
    use WebService::GData;
    use base 'WebService::GData';
    
    #install simple setters; it could also be setter/getters
    WebService::GData::install_in_package([qw(firstname lastname age gender)],sub {
            my $func = shift;#firstname then lastname then age...
            return sub {
                my $this = shift;
                return $this->{$func};
            }
    });

    1;

    #in user code:

    my $user = new Basic::User(firstname=>'doe',lastname=>'john',age=>100,gender=>'need_confirmation');

    $user->age;#100
    $user->firstname;#doe



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

shiriru E<lt>shirirulestheworld[arobas]gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
