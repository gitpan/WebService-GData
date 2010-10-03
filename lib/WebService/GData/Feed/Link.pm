package WebService::GData::Feed::Link;
use WebService::GData;
use base 'WebService::GData';
use WebService::GData::Error;

our $VERSION = 0.01_01;

sub __init {
    my ( $this, $link ) = @_;
    die new WebService::GData::Error('invalid_parameter_type',"Link parameter must be a hash reference but got:" . ref($link))
      unless ( ref($link) eq 'HASH' );
    $this->{_link} = $link;
}

WebService::GData::install_in_package([qw(rel type href)], sub {
    my $sub = shift;
    return sub {
        my $this = shift;
        $this->{_link}->{$sub} = $_[0] if ( @_ == 1 );
        $this->{_link}->{$sub};        
    }
});


"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Feed::Link - Represent an xml Link tag.

=head1 SYNOPSIS

    use WebService::GData::Feed;
    
    my $feed = new WebService::GData::Feed($jsonfeed);
    
   my $links=  $feed->links();
   
   foreach my $link (@$links){
       #print $link->rel,$link->type, $link->href;
   }


=head1 DESCRIPTION

I<inherits from L<WebService::GData::Feed>>

This package wraps the link data found in a feed using the json format of the Google Data API v2 (no other format is supported!).


=head1 CONSTRUCTOR

=head2 new

=over

Accept the content of the link tag from a feed that has been perlified (from_json($json_string)).

B<Parameters>

=over 4

=item C<link_info:HashRef> - link data coming from a json feed.

=back

B<Returns>

=over 4

=item C<WebService::GData::Feed::Link>

=back


B<Throws>

=over 4

=item C<WebService::GData::Error> - invalid_parameter_type if it is not an hash reference.

=back

Example:

    use WebService::GData::Feed::Link;
    
    my $link = new WebService::GData::Feed::Link($jsonfeed->{link}->[0]);
    
    #or
    my $link = new WebService::GData::Feed::Link({
        rel =>"alternate",
        type => "text/html",
        href => "http://www.youtube.com"
    });    
    
    $link->rel();#alternate

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
    
    $feed->name("john");
    
    $feed->name();#john

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
    
    $feed->uri("http://www.youtube.com/john");
    
    $feed->uri();#"http://www.youtube.com/john"

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
