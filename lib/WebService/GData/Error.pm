package WebService::GData::Error;
use WebService::GData;
use base 'WebService::GData';
use WebService::GData::Error::Entry;
our $VERSION  = 0.01_01;
	#avoid stringification
	sub __to_string {
		shift();
	}

	sub __init {
		my ($this,$statecode,$errstr) = @_;
		$this->{_statecode} = $statecode;
		$this->{_errstr}    = $errstr;

		$this->{_errors} = [];
		$this->_parse();
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

=head1 VERSION

0.01

=head1 SYNOPSIS

	use WebService::GData::Error;

    #create an error object that you can throw by dying...
   	my $error = new WebService::GData::Error(401,'Unauthorized');
	# $error->code;
	# $error->content;
	#die $error;

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

inherits from WebService::GData;

This package can parse error response from Google APIs service. You can also create your own basic error.

All WebService::GData::* classes die a WebService::GData::Error object when something went wrong.

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


=head1 METHODS


=head2 new (code:Int,content:Scalar)

=over

Accept two parameters: a code number (ie,a http status code) and a string.

The string can be a Google xml error response, in which case, it will parse the contents and give you access to it via errors() method. 

=head2 code

=over

Get back the error code.

=head2 content

=over

Get back the raw content of the error.

When getting an error from querying one of Google data services, you will get an xml response containing possible errors.

In such case,you should loop through the result of errors() which send back WebService::GData::Error::Entry.


=head2 errors 

=over

Get back a reference array filled with  WebService::GData::Error::Entry.

When getting an error from querying one of Google data services, you will get an xml response containing possible errors.

In such case,you should loop through the result of errors() which send back WebService::GData::Error::Entry.

errors allways send back a reference array (even if there is no error).

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

L<JSON>

L<LWP>

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