package WebService::GData::Feed::Entry::Content;
use WebService::GData;
use base 'WebService::GData';
use WebService::GData::Error;

our $VERSION = 0.01_01;

sub __init {
    my ( $this, $link ) = @_;
    die new WebService::GData::Error('invalid_parameter_type',"Link parameter must be a hash reference but got:" . ref($link))
      unless ( ref($link) eq 'HASH' );
    $this->{_content} = $link;
}

WebService::GData::install_in_package([qw(src type)], sub {
    my $sub = shift;
    return sub {
        my $this = shift;
        $this->{_content}->{$sub} = $_[0] if ( @_ == 1 );
        $this->{_content}->{$sub};        
    }
});


"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Feed::Entry::Content - Represent an xml Entry Content tag.

=head1 SYNOPSIS

    use WebService::GData::Feed::Entry;
    
    my $feed = new WebService::GData::Feed::Entry($jsonentry);
    
   my $content=  $feed->content();
   $content->type();#"application/x-shockwave-flash"
   $content->src();#http://www.youtube.com/v/qW...YvHqLE



=head1 DESCRIPTION

I<inherits from L<WebService::GData>>

This package wraps the content data found in a entry tag of a feed using the json format of the Google Data API v2 (no other format is supported!).


=head1 CONSTRUCTOR

=head2 new

=over

Accept the data of the content tag found in a entry tag of a feed that has been perlified (from_json($json_string)).

B<Parameters>

=over 4

=item C<content_info:HashRef> - content data coming from a json feed entry tag.

=back

B<Returns>

=over 4

=item C<WebService::GData::Feed::Entry::Content>

=back


B<Throws>

=over 4

=item C<WebService::GData::Error> - invalid_parameter_type if it is not an hash reference.

=back

Example:

    use WebService::GData::Feed::Entry::Content;
    
    my $link = new WebService::GData::Feed::Entry::Content($jsonentry->{content});
    
    #or
    my $content = new WebService::GData::Feed::Entry::Content({
        src =>"http://www.youtube.com",
        type => "text/html",
    });    
    
    $content->src();#"http://www.youtube.com"

=back

=head1 GET/SET METHODS


=head2 src

=over

get/set the src of the content.

B<Parameters>

=over 4

=item C<none> - as a getter

=item C<src:Scalar> as a setter

=back

B<Returns>

=over 4

=item C<none> - as a setter

=item C<src:Scalar> as a getter

=back

Example:

    use WebService::GData::Feed::Entry::Content;
    
    my $link = new WebService::GData::Feed::Entry::Content($jsonentry->{content});
    
    $link->src("http://www.youtube.com/v/qWAY3...vHqLE");
    
    $link->src();#http://www.youtube.com/v/qWAY3...vHqLE

=back


=head2 type

=over

get/set the type of the content.

B<Parameters>

=over 4

=item C<none> - as a getter

=item C<type:Scalar> as a setter

=back

B<Returns>

=over 4

=item C<none> - as a setter

=item C<type:Scalar> as a getter

=back

Example:

    use WebService::GData::Feed::Entry::Content;
    
    my $link = new WebService::GData::Feed::Entry::Content($jsonentry->{content});
    
    $link->type("text/html");
    
    $link->type();#text/html

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
