package WebService::GData::Error::Entry;
use WebService::GData;
use base 'WebService::GData';
our $VERSION  = 0.01_01;
WebService::GData::install_in_package([qw(internalreason domain code location)],
	sub {
		my $func=shift;
	    return sub {
			my $this = shift;
			if(@_==1){
				$this->{$func}=$_[0];
			}
			return $this->{$func};
		};
});

	sub __init {
		my ($this,$xmlerror) = @_;
		$this->_parse($xmlerror);
	}

	sub _parse {
		my ($this,$error) = @_;
		if($error){
			my ($domain)  = $error=~m/<domain>(.+?)<\/domain>/;
			my ($code)    = $error=~m/<code>(.+?)<\/code>/;
			my $location  = {};
			($location->{type})    = $error=~m/<location\s+type='(.+?)'>/gmxi;

			($location->{content}) = $error=~m/'>(.+?)<\/location>/gmxi;
			my ($internalreason)   = $error=~m/<internalreason>(.+?)<\/internalreason>/gmxi;
			$this -> code($code);
			$this -> internalreason($internalreason);
			$this -> domain($domain);
			$this -> location($location);
		}
	}

	sub serialize {
		my $this = shift;
		my $xml='<error>';
		   $xml.='<internalreason>'.$this->internalreason.'</internalreason>' if($this->internalreason);
		   $xml.='<code>'.$this->code.'</code>' if($this->code);
		   $xml.='<domain>'.$this->domain.'</domain>' if($this->domain);	
		   $xml.="<location type='".$this->location->{type}.'>'.$this->location->{content}.'</location>' if($this->location);
	       $xml.='</error>';
		return $xml;
	}

"The earth is blue like an orange.";

__END__

=pod

=head1 NAME

WebService::GData::Error::Entry - wrap an xml error sent back by Google data APIs v2.

=head1 VERSION

0.01

=head1 SYNOPSIS

	use WebService::GData::Error;

    #parse an error from a Google data API server...
   	my $entry = new WebService::GData::Error::Entry($xmlerror);
	$entry->code;
	$entry->internalreason;
	$entry->domain;
	$entry->location->{type};#this is just a hash
	$entry->location->{content};#this is just a hash

    #create an error from a Google data API server...
   	my $entry = new WebService::GData::Error::Entry();
	$entry->code('too_long');
	$entry->domain('your_domain');
	$entry->location({type=>'header',content=>'Missing Version header'});
	print $entry->serialize()#return <error>...</error> entry




=head1 DESCRIPTION

inherits from WebService::GData;

This package can parse error response from Google APIs service. You can also create your own basic xml error.

All WebService::GData::* classes die a WebService::GData::Error object when something went wrong.

You should use an eval {}; block to catch the error.

Example:

	use WebService::GData::Error;

    #parse an error from a Google data API server...
   	my $entry = new WebService::GData::Error::Entry($xmlerror);
	$entry->code;
	$entry->internalreason;
	$entry->domain;
	$entry->location->{type};#this is just a hash
	$entry->location->{content};#this is just a hash

    #create an error from a Google data API server...
   	my $entry = new WebService::GData::Error::Entry();
	$entry->code('too_long');
	$entry->domain('your_domain');
	$entry->location({type=>'header',content=>'Missing Version header'});



=head1 METHODS

=head2 new (content:Scalar)

=over

=head2 code

=over

Get/set an error code.

=head2 location

=over

Get/set the error location as an xpath.

It requires an hash with type and content as keys.

=head2 domain

=over

Get/set the type of error. Google data API has validation,quota,authentication,service errors.

=head1 SEE ALSO

Format of the errors, kind of errors and details:

L<http://code.google.com/intl/en/apis/youtube/2.0/developers_guide_protocol_error_responses.html>


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