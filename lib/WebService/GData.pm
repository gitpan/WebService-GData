package WebService::GData;
use 5.008008;
use strict;
use warnings;
use Data::Dumper;
use Carp;
use overload '""' => "__to_string";

our $VERSION = 0.02_09;

sub import {
    strict->import;
    warnings->import;
    my $import  = shift;
    my $package = caller;
    if ($import) {
        install_in_package( ['private'], sub { return \&private; }, $package );
    }
}

sub new {
    my $package = shift;
    my $this    = {};
    bless $this, $package;
    $this->__init(@_);
    return $this;
}

sub __init {
    my ( $this, %params ) = @_;
    while ( my ( $prop, $val ) = each %params ) {
        $this->{$prop} = $val;
    }
}

sub __to_string {
    return Dumper(shift);
}

sub install_in_package {
    my ( $subnames, $callback, $package ) = @_;

    $package = $package || caller;
    return if ( $package eq 'main' );    #never import into main
    {                                    #install
        no strict 'refs';
        no warnings 'redefine';
        foreach my $sub (@$subnames) {
            *{ $package . '::' . $sub } = &$callback($sub);
        }
    }

}

sub private {
    my ( $name, $sub ) = @_;
    my $package = caller;
    install_in_package(
        [$name],
        sub {
            return sub {
                my @args = @_;
                my $p    = caller;
                croak {
                    code    => 'forbidden_access',
                    content => 'private method called outside of its package'
                  }
                  if ( $p ne $package );
                return &$sub(@args);
              }
        },
        $package
    );
}

sub disable {
    my ( $parameters, $package ) = @_;
    $package = $package || caller;
    install_in_package(
        $parameters,
        sub {
            return sub {

                #keep the chaining
                return shift();
              }
        },
        $package
    );

}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData - Google data protocol v2 base object to inherit from.

=head1 SYNOPSIS

    package WebService::MyService;
    use WebService::GData;#strict/warnings turned on
    use base 'WebService::GData';

    #this is the base implementation of the __init method in WebService::GData
    #it is call when new() is used. only overwrite it if necessary.

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

    my $object = new WebService::MyService(name=>'test');

    $object->name;#test

    #overloaded string will dump the object with Data::Dumper;
	
    print $object;#$VAR1 = bless( { 'name' => 'test' }, 'WebService::MyService' );


=head1 DESCRIPTION

This package is a blueprint that you should inherit and extend. It offers a basic hashed based object creation via the word new. 

All sub classes should be hash based. If you want to pock into the instance, it's easy but everything that is not documented 
should be considered private. If you play around with undocumented properties/methods and that it changes,upgrading to the new version with all 
the extra new killer features will be very hard to do. 

so...

dont.

The following classes extends L<WebService::GData> to implement their feature:

=over

=item L<WebService::GData::Base>

Implements the base get/post/insert/update/delete methods for the Google data protocol.

=item L<WebService::GData::ClientLogin>

Implements the ClientLogin authorization system.

=item L<WebService::GData::Error>

Represents a Google data protocol Error.

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

=over 

Takes an hash which keys will be attached to the instance.
You can also use C<install_in_package()> to create setters/getters for these parameters.

B<Parameters>

=over 4

=item C<parameters:Hash>

=back

B<Returns> 

=over 4

=item C<WebService::GData>

=back

Example:


    my $object = new WebService::GData(firstname=>'doe',lastname=>'john',age=>'123');

    $object->{firstname};#doe
	
=back

=head2 METHODS

=head3 __init

=over

This method is called by the constructor C<new()>.
This function receives the parameters set in C<new()> and assign the key/values pairs to the instance.
You should overwrite it and add your own logic.

=back

=head2 OVERLOAD

=head3 __to_string

=over

Overload the stringification quotes and display a dump of the instance by using L<Data::Dumper>. 
You should overwrite it should you need to create a specific output.

=back

=head2  SUBS

=head3 install_in_package

=over

Install in the package the methods/subs specified. Mostly use to avoid writting boiler plate getter/setter methods.

B<Parameters>

=over 4

=item C<subnames:ArrayRef> - Should list the name of the methods you want to install in the package.

=item C<callback:Sub> - The callback will receive the name of the function. This callback should itself send back a function.

=item C<package_name:Scalar> (optional) - Add functions at distance by specifying an other module.

=back

B<Returns> 

=over 4

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
	
=back

=head3 private

=over

Create a method that is private to the package. Calling a private function from outside of the package will throw an error.

You can import the private method:

    use WebService::GData 'private';

B<Parameters>

=over

=item C<function_name_with_sub:Hash> - Accept an hash which key is the function name and value a sub.

=back

B<Returns> 

=over 4 

=item C<void>

=back

B<Throws> 

=over 4 

=item C<error:RefHash> - an hash containing the code: 'forbidden_access' and the content:'private method called outside of its package'.

=back

Example:

    package Basic::User;
    use WebService::GData 'private';
    use base 'WebService::GData';
    
    private my_secret_method => sub {
		
    };  #note the comma

    1;

    #in user code:
	
    my $user = new Basic::User();

    $user->my_secret_method();#throw an error
	
    eval {
        $user->my_secret_method();
    };
    if(my $error = $@){
        #$error->{code};
        #$error->{content};
    }
	
=back

=head3 disable

=over

Overwrite a method so that it does nothing...
Some namespaces inherit from functionalities that are not required.
The function will still be available but will just return the instance.

B<Parameters>

=over

=item C<functions:ArrayRef> - array reference containing the functions to disable 

=item C<package:Scalar*> - (optional) By default it uses the package in which it is called but you can specify a package.

=back

B<Returns> 

=over 4 

=item C<void>

=back


Example:

    package Basic::User;
    use WebService::GData;
    use base 'WebService::GData::Feed';
    
    WebService::GData::disable("etag","title");

    1;

    #in user code:
	
    my $user = new Basic::User();

    $user->etag("ddd")->title("dddd");#does nothing at all

	
=back


=head1 BUGS AND LIMITATIONS

If you do me the favor to _use_ this module and find a bug, please email me
i will try to do my best to fix it (patches welcome)!

=head1 AUTHOR

shiriru E<lt>shirirulestheworld[arobas]gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
