package WebService::GData::Collection;
use base 'WebService::GData::BaseCollection';

our $VERSION =0.01_03;

use Data::Dumper;
sub __init {
    my $this = shift;
    $this->SUPER::__init(@_);
    #lookup table to store the result from a search
    $this->{cache}={};
}

sub nodes {
    my $this = shift;
    $this->{array}
}

sub __set {
	my ($this,$attr,$val)=@_;
	
	#only scalar value allowed
	return [] if(ref($val)||ref($attr));
	
	if($this->{cache}->{$attr.$val}){
		return $this->{cache}->{$attr.$val};
	}

	$this->{cache}->{$attr.$val}=[];
	my @ret= ();
	foreach my $elm (@{ $this->nodes }){
	    
		if($elm->$attr()=~m/$val/) {
		   push @ret,$elm;
		}
	}
   $this->{cache}->{$attr.$val}=\@ret;
   
   $this->{cache}->{$attr.$val}
}

sub __get {
	my ($this,$func)=@_;
	
	my @ret =();
	foreach my $elm (@{ $this->nodes }){
		push @ret,$elm->$func();
	}
	
	\@ret
}



"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Collection - Composite class redispatching method calls to query the items data.

=head1 SYNOPSIS

    use WebService::GData::Collection;

    #array ref of link nodes
    my $links = new WebService::GData::Collection($links);

    #search through the nodes for a certain value
    my $reponse_url = $links->rel('video.responses')->[0];
   
    #access the object as if it was an array reference
    $links->[0];
    
    #loop through it as if it was a normal array reference
    foreach my $link (@$links) {
        #$link->rel...
    }


=head1 DESCRIPTION

I<inherits from L<WebService::GData::BaseCollection>>

This package accepts an array reference containing identic nodes (link nodes, category nodes,video nodes...).
Once feed with some data, you can call a node method by specifying a search string.
The instance will simply redispatch the call to all its children and return any children that match(=~m/$search/) your query.


=head3 CONSTRUCTOR

=head3 new

=over

Create a Collection instance.

B<Parameters>

=over 4

=item C<collection:ArrayRef> - (optional) an array reference of nodes or identic instances.

=back

B<Returns> 

=over 4

=item C<WebService::GData::Collection> instance

=back

B<Example>

    use WebService::GData::Collection;
    
    my $collection = new WebService::GData::Collection();
    
    $collection->[0] = new WebService::GData::Node::AuthorEntity();
    
    or
    my $collection = new WebService::GData::Collection(\@authors);     

=back



=head2 OVERLOAD

=over

In order to fake array reference behavior, the array reference context is overloaded to return the actual array stored in the instance.

B<Example>

    use WebService::GData::Collection;

    my $authors = new WebService::GData::Collection(\@authors);     
    
    foreach my $author (@$authors) {
        $author->name;
    }
    
    push @$author,new WebService::GData::Node::AuthorEntity();

=back


=head3 nodes

=over

This method returns the array reference stored in the instance and is used for overloading the array reference mechanism.

B<Parameters>

=over 

=item C<none>
=back

B<Returns> 

=over 

=item L<items::ArrayRef>

=back


Example:

    my $collection = new WebService::GData::Collection(\@authors); 
    
    my $authors = $collection->nodes;
	
=back

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
