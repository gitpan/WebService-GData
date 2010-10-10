package WebService::GData::Feed::Author;
use WebService::GData;
use base 'WebService::GData';
use WebService::GData::Error;

our $VERSION = 0.01_01;

sub __init {
    my ( $this, $author ) = @_;
    die new WebService::GData::Error('invalid_parameter_type',"Author parameter must be a hash reference but got:" . ref($author))
      unless ( ref($author) eq 'HASH' );
    $this->{_author} = $author;
}

sub name {
    my $this = shift;
    $this->{_author}->{name}->{'$t'} = $_[0] if ( @_ == 1 );
    $this->{_author}->{name}->{'$t'};
}

sub uri {
    my $this = shift;
    $this->{_author}->{uri}->{'$t'} = $_[0] if ( @_ == 1 );
    $this->{_author}->{uri}->{'$t'};
}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Feed::Author - Represent an xml author tag.

=head1 SYNOPSIS

    use WebService::GData::Feed;
    
    my $feed = new WebService::GData::Feed($jsonfeed);
    
   my $authors=  $feed->author();
   
   foreach my $author (@$authors){
       #print $author->name,$author->uri;
   }


=head1 DESCRIPTION

I<inherits from L<WebService::GData>>

This package wraps the author data found in a feed using the json format of the Google Data API v2 (no other format is supported!).


=head1 CONSTRUCTOR

=head2 new

=over

Accept the content of the author tag from a feed that has been perlified (from_json($json_string)).

B<Parameters>

=over 4

=item C<author_info:HashRef> - author data coming from a json feed.

=back

B<Returns>

=over 4

=item C<WebService::GData::Feed::Author>

=back


B<Throws>

=over 4

=item C<WebService::GData::Error> - invalid_parameter_type if it is not an hash reference.

=back

Example:

    use WebService::GData::Feed::Author;
    
    my $author = new WebService::GData::Feed::Author($jsonfeed->{author}->[0]);
    
    #or
    my $author = new WebService::GData::Feed::Author({
        name => {
            '$t'=>'john'
        },
        uri => {
            '$t'=>'http://www.google.com/'
        }
    });    
    $author->name("john");
    
    $author->name();#john

=back

=head1 GET/SET METHODS


=head2 name

=over

get/set the name of the author.

B<Parameters>

=over 4

=item C<none> - as a getter

=item C<name:Scalar> as a setter

=back

B<Returns>

=over 4

=item C<none> - as a setter

=item C<name:Scalar> as a getter

=back

Example:

    use WebService::GData::Feed::Author;
    
    my $author = new WebService::GData::Feed::Author($jsonfeed->{author}->[0]);
    
    $author->name("john");
    
    $author->name();#john

=back


=head2 uri

=over

get/set the uri of the author.

B<Parameters>

=over 4

=item C<none> - as a getter

=item C<uri:Scalar> as a setter

=back

B<Returns>

=over 4

=item C<none> - as a setter

=item C<uri:Scalar> as a getter

=back

Example:

    use WebService::GData::Feed::Author;
    
    my $author = new WebService::GData::Feed::Author($jsonfeed->{author}->[0]);
    
    $author->uri("http://www.youtube.com/john");
    
    $author->uri();#"http://www.youtube.com/john"

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
