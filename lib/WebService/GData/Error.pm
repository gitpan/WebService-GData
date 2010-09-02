package WebService::GData::Error;
use WebService::GData;
use base 'WebService::GData';

use WebService::GData::Error::Entry;

our $VERSION  = 0.01_02;

	#avoid stringification
	sub __to_string {
		shift();
	}

	sub __init {
		my ($this,$statecode,$errstr) = @_;
		$this->{_statecode} = $statecode;
		$this->{_errstr}    = $errstr;

		$this->{_errors} = [];
		$this->_parse() if($errstr);
		return $this;
	}

	sub code {
		my $this = shift;
		return $this->{_statecode};
	}

	sub content {
		my $this = shift;
		return $this->{_errstr};
	}

	sub _parse {
		my ($this) = @_;
		my @errors = $this->{_errstr}=~m/<error>(.+?)<\/error>/gms;
		foreach my $error (@errors) {
		   my $entry  = new WebService::GData::Error::Entry($error);
		   push @{$this->{_errors}},$entry;
		}
	}

	sub errors {
		my $this = shift;
		return $this->{_errors};
	}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Error - create an error and parse errors from Google data APIs v2.


=head1 SYNOPSIS

    use WebService::GData::Error;

    #create an error object that you can throw by dying...
    my $error = new WebService::GData::Error(401,'Unauthorized');
    # $error->code;
    # $error->content;

    #create an error object in response to a Google Service.
    my $error = new WebService::GData::Error(401,$responseFromAService);
    print $error->code;
    print $error->content;#raw xml content

    my @errors = $error->errors;#send back WebService::GData::Error::Entry objects

    foreach my $error (@{$error->errors}){
        print $error->code;
        print $error->internalreason;
        print $error->domain;
        print $error->location->{type};#this is just a hash
        print $error->location->{content};#this is just a hash
    }



=head1 DESCRIPTION

I<inherits from WebService::GData>.

This package can parse error response from Google APIs service. You can also create your own basic error.

All WebService::GData::* classes die a WebService::GData::Error object when something goes wrong.

You should use an eval {}; block to catch the error.

Example:

    use WebService::GData::Base;


    my $base = new WebService::GData::Base();
    eval {
        $base->get($url);
    };
    #$error is a WebService::GData::Error;
    if(my $error=$@){
        #error->code,$error->content, $error->errors
    }


=head2 CONSTRUCTOR


=head3 new 

Create a WebService::GData::Error instance.

I<Parameters>:

=over

=item C<code:*>

This could be an http status or a short string error_code.

=item C<content:Scalar>

The string can be a Google xml error response, in which case, 

it will parse the contents that you can access via the errors() method of the instance. 

=over

I<Return>:

=over

=item L<WebService::GData::Error>

=back

Example:

    use WebService::GData::Error;

    #create an error object that you can throw by dying...
    my $error = new WebService::GData::Error(401,'Unauthorized');


=head2 GET METHODS

=head3 code

Get back the error code.

I<Return>:

=over

=item L<code:Scalar>

=back

=head3 content

Get back the raw content of the error.

When getting an error from querying one of Google data services, you will get a raw xml response containing possible errors.

In such case,you should loop through the result by using the errors() instance which send back L<WebService::GData::Error::Entry>.

I<Return>:

=over

=item L<content:Scalar>

=back

=head3 errors

Get back a reference array filled with  L<WebService::GData::Error::Entry>.

When getting an error from querying one of Google data services, you will get an xml response containing possible errors.

In such case,you should loop through the result of errors().

Errors always send back a reference array (even if there is no error).

I<Return>:

=over

=item L<WebService::GData::Error::Entry>

=back

Example:

    my @errors = $error->errors;#send back WebService::GData::Error::Entry objects

    foreach my $error (@{$error->errors}){
        print $error->code;
        print $error->internalreason;
        print $error->domain;
        print $error->location->{type};#this is just a hash
        print $error->location->{content};#this is just a hash
    }


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