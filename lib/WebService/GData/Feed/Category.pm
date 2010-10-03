package WebService::GData::Feed::Category;
use WebService::GData;
use base 'WebService::GData';
use WebService::GData::Error;

our $VERSION = 0.01_01;

sub __init {
    my ( $this, $category ) = @_;
    die new WebService::GData::Error('invalid_parameter_type',"Category parameter must be a hash reference but got:" . ref($category))
      unless ( ref($category) eq 'HASH' );
    $this->{_category} = $category;
}

WebService::GData::install_in_package([qw(scheme term label)], sub {
    my $sub = shift;
    return sub {
        my $this = shift;
        $this->{_category}->{$sub} = $_[0] if ( @_ == 1 );
        $this->{_category}->{$sub};        
    }
});

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Feed::Category - Represent an xml category tag.

=head1 SYNOPSIS

    use WebService::GData::Feed;
    
    my $feed = new WebService::GData::Feed($jsonfeed);
    
    my $categories=  $feed->category();
   
    foreach my $category (@$categories){
       #print $category->scheme,$category->term,$category->label;
    }


=head1 DESCRIPTION

I<inherits from L<WebService::GData::Feed>>

This package wraps the category data found in a feed using the json format of the Google Data API v2 (no other format is supported!).


=head1 CONSTRUCTOR

=head2 new

=over

Accept the content of the category tag from a feed that has been perlified (from_json($json_string)).

B<Parameters>

=over 4

=item C<category_info:HashRef> - category data coming from a json feed.

=back

B<Returns>

=over 4

=item C<WebService::GData::Feed::Category>

=back


B<Throws>

=over 4

=item C<WebService::GData::Error> - invalid_parameter_type if it is not an hash reference.

=back

Example:

    use WebService::GData::Feed::Category;
    
    my $category = new WebService::GData::Feed::Category($jsonfeed->{category}->[0]);
    
    #or
    my $category = new WebService::GData::Feed::Category({
        scheme => 'http://gdata.youtube.com/schemas/2007/categories.cat',
        term => 'Shows',
        label => 'Shows',
    });    
    
    $category->term();#Shows

=back

=head1 GET/SET METHODS


=head2 scheme

=over

get/set the scheme of the category.

B<Parameters>

=over 4

=item C<none> - as a getter

=item C<scheme:Scalar> as a setter

=back

B<Returns>

=over 4

=item C<none> - as a setter

=item C<scheme:Scalar> as a getter

=back

Example:

    use WebService::GData::Feed::Category;
    
    my $category = new WebService::GData::Feed::Category($jsonfeed->{category}->[0]);
    
    $category->scheme("http://schemas.google.com/g/2005#kind");
    
    $category->scheme();#http://schemas.google.com/g/2005#kind

=back


=head2 term

=over

get/set the term of the category.

B<Parameters>

=over 4

=item C<none> - as a getter

=item C<term:Scalar> as a setter

=back

B<Returns>

=over 4

=item C<none> - as a setter

=item C<term:Scalar> as a getter

=back

Example:

    use WebService::GData::Feed::Category;
    
    my $category = new WebService::GData::Feed::Category($jsonfeed->{category}->[0]);
    
    $category->term("http://gdata.youtube.com/schemas/2007#video");
    
    $category->term();#http://gdata.youtube.com/schemas/2007#video

=back

=head2 label

=over

get/set the label of the category.

B<Parameters>

=over 4

=item C<none> - as a getter

=item C<label:Scalar> as a setter

=back

B<Returns>

=over 4

=item C<none> - as a setter

=item C<label:Scalar> as a getter

=back

Example:

    use WebService::GData::Feed::Category;
    
    my $category = new WebService::GData::Feed::Category($jsonfeed->{category}->[0]);
    
    $category->label("comedy");
    
    $category->label();#comedy

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
