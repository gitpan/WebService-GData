package WebService::GData::Node;
use WebService::GData;
use base 'WebService::GData';

our $VERSION = 0.01_01;

my $attributes = [];

sub import {
    shift();
    my $package = shift() || caller;
    return if ( $package->isa(__PACKAGE__) || $package eq 'main' );
    WebService::GData->import;
    WebService::GData::install_in_package( ['set_xml_meta'],
        sub { return \&set_xml_meta; }, $package );

    {
        no strict 'refs';
        push @{ $package . '::ISA' }, __PACKAGE__;
        my $pk = $package;
        $package =~ s/.*:://;
        *{ $pk . '::tag_name' } = sub {
            return "\l$package";
          }
    }
}

sub set_xml_meta {
    my %data    = @_;
    my $package = caller;
    return if ( $package eq __PACKAGE__ );
    {
        no strict 'refs';
        no warnings 'redefine';
        while ( my ( $sub, $val ) = each %data ) {
            *{ $package . '::' . $sub } = sub {
                return $val;
              }
        }

    }
}

sub __init {
    my ( $this, @args ) = @_;

    if ( ref( $args[0] ) eq 'HASH' ) {

        #accept a text tag but json feed uses $t tag so adapt
        #for compatibility
        if ( $args[0]->{'$t'} ) {
            $args[0]->{'text'} = $args[0]->{'$t'};
            delete $args[0]->{'$t'};
        }
        @args = %{ $args[0] };
    }

    $this->SUPER::__init(@args);
    $this->{_children} = [];
}

sub root_name  { ""          }

sub tag_name   { ""          }

sub attributes { $attributes }

sub is_parent  { 1           }

sub __to_string {
    return +shift->serialize;
}

sub child {
    my $this = shift;
    if ( @_ == 1 ) {
        my $child = shift;
        return $this
          if ( $this == $child || !$child->isa(__PACKAGE__) );    #TODO:warn
        push @{ $this->{_children} }, $child;
        return $this;
    }
    return $this->{_children};
}

sub serialize {
    my $this = shift;
    my $tag =
        $this->root_name
      ? $this->root_name() . ':' . $this->tag_name()
      : $this->tag_name();
    my $out = qq[<$tag];
    if ( @{ $this->attributes } > 0 ) {
        my @attrs = ();
        foreach my $attr ( @{ $this->attributes } ) {
            my $val = $this->{$attr};
            push @attrs, qq[$attr="$val"] if ($val);
        }
        $out .= ' ' . join( ' ', @attrs );
    }
    if ( $this->is_parent ) {
        $out .= '>';
        $out .= $this->{text} if ( $this->{text} );
        my $children = $this->child;
        foreach my $child (@$children) {
            $out .= $child->serialize;
        }
        $out .= qq[</$tag>];
    }
    else {
        $out .= '/>';
    }
    return $out;
}

sub __set {
    my ($this,$func,@args) = @_;
    if(my ($ns,$tag)=$func=~/^(.+?)_(.+)$/){
        my @attrs =  @{ $this->attributes };
        my $attr = $ns.':'.$tag;
        if(grep /$attr/,@attrs){
           $func=$attr;          
        }
    }
    $this->{$func}= @args==1 ? $args[0]:\@args;
    return $this;
}


"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Node - Abstract class representing an xml node/tag

=head1 SYNOPSIS

   #your package should use the abstract Node package.
   #it will automaticly inherit from it.
   
   #Author.pm files:
   use WebService::GData::Node::Author;
   use WebService::GData::Node;
   
   1;
   
   #Name.pm
   use WebService::GData::Node::Name;
   use WebService::GData::Node;  
   
   1; 
   
   #Category.pm
   package WebService::GData::Node::Category;
   use WebService::GData::Node;

   set_xml_meta(
        attributes=>['scheme','yt:term','label'],#default to []
        is_parent => 0, #default 1
        root_name => 'k', #default to ''
        tag_name  => 'category' # default to the package file name with the first letter in lower case
   );

   1;

    #user code:
	use WebService::GData::Node::Name();  #avoid to inherit from it by not importing
	use WebService::GData::Node::Author();
	use WebService::GData::Node::Category();
		
    my $author   = new WebService::GData::Node::Author();
    my $name     = new WebService::GData::Node::Name(text=>'john doe');
    my $category = new WebService::GData::Node::Category(scheme=>'author',term=>'Author');
    
    $author->child($name)->child($category);
    
    $name->text;#john doe
    $category->scheme;#author;
    $category->scheme('compositor');
    
    print $author;#<author><name>john doe</name><k:category scheme="compositor" yt:term="Author"/></author>



=head1 DESCRIPTION

I<inherits from L<WebService::GData>>

This package is an abstract class representing the information required to serialize a node object into xml.
It regroups the mechanism to store the meta data about a node and from there built the proper xml output.
It is not an all purpose class for building complex xml data. It does not parse xml either. 

You should subclass and set the meta information via the C<set_xml_data> function that will be installed in your package
 (see below for further explanation).
You can instantiate this class if you want... it will not throw any error but you won't be able to do much. 

A node is only the representation of one xml tag. Feed and Feed subclasses are the representation of an entire JSON response
or offers a subset.

See also L<WebService::GData::Node::AbstractEntity>.


=head2 CONSTRUCTOR

=head3 new

=over

Create an instance but you won't be able to do much as no meaningful meta data has been set. You should
inherit from this class.

B<Parameters>

=over 

=item C<args:Hash> (optional) - all the xml attributes can be set here. text nodes requires the "text" key.
or

=item C<args:HashRef> (optional) - all the xml attributes can be set here. text nodes requires the "text" key and 
the '$t' key is also supported as an alias for 'text' for compatibily with the GData JSON responses.

=back

B<Returns> 

=over 

=item L<WebService::GData::Node>

=back


Example:

    use WebService::GData::Node;
	
    my $node   = new WebService::GData::Node(text=>'hi');
    
       $node->text();#hi;
       
   print $node;"<>hi<>"; #this is an abstract node!
	
=back

=head2 OVERLOAD METHOD

=head3 __to_string

=over

This class overwrite the default __to_string method to call C<serialize> and output the xml data.
Therefore if you use a Node object in a string context, you will get back its xml representation.

=head2 METHODS

=head3 child

=over

Set an other node child of the instance. It returns the instance so you can chain the calls.
The child must be sub class of this class and you can not set the instance as a child of itself.
The child method checks against the memory slot of the object and will return the instance without setting the object 
if it appears to be the same.

=back

B<Parameters>

=over

=item C<node:WebService::GData::Node> - a node instance inheriting from this class.

=back

B<Returns> 

=over 

=item C<instance:WebService::GData::Node> - you can chain the call

=back

Example:

    my $author   = new WebService::GData::Node::Author();
    my $name     = new WebService::GData::Node::Name(text=>'john doe');
    my $category = new WebService::GData::Node::Category(scheme=>'author',term=>'Author');
    
    $author->child($name)->child($category);
    
    #the same object can not be a child of itself. which makes sense.
    #it just silently returns the instance.
    $author->child($author);


=back

=head3 serialize

=over

This method will create the xml output of the instance and make recursive call to the serialize method of the children.

B<Parameters>

=over

=item C<none>

=back

B<Returns> 

=over 

=item C<xml_data:Scalar> - the xml created

=back

Example:

    my $author   = new WebService::GData::Node::Author();
    my $name     = new WebService::GData::Node::Name(text=>'john doe');
    my $category = new WebService::GData::Node::Category(scheme=>'author',term=>'Author');
    
    $author->child($name)->child($category);
    
    $author->serialize;#<author><name>john doe</name><k:category scheme="author" yt:term="Author"/></author>
	   
=back

=head 2 STATIC GETTER METHODS

The following methods are installed by default in the package subclassing this class.
You should set their value via the C<set_xml_data> method (see below).

=head3 root_name

=head3 tag_name

=head3 attributes

=head3 is_parent
	  

=head2 INHERITANCE

The package will push itself in the inheritance chain automaticly when you use it so it is not necessary to explicitly
declare the inheritance. As a consequence though, every sub classes that are used will also automaticly set themself
 in the inheritance chain of the C<use>r. In order to avoid this behavior you should write:
 
    use WebService::GData::Node(); 
 
The following function will be accessible in the sub class.

=head3 set_xml_data

=over

Set the meta data of the node.

B<Parameters>

=over

=item C<args::Hash> 

=over

=item B<root_name:Scalar> - the namespace name of the tag, ie, yt:, media: ...

=item B<tag_name:Scalar>  - the name of the tag it sefl, ie, category, author...

=item B<attributes:ArrayRef> - a list of the node attributes, ie, src, scheme... Default: []

=item B<is_parent:Int> - specify if the node can accept children, including text node. Default: 1 (true),0 if not.


=back

B<Returns> install the methods in the package.

Methods to get/set the attributes are autogenerated on the fly. Attributes containing namespaces can be accessed by replacing ':' with
'_'. yt:format attribute can be set/get via the yt_format method. You should use the qualified attribute when setting it via the constructor.
Therefore, new Node(yt_format=>1) will not work but new Node('yt:format'=>1) will.
=over 

=item C<none>

=back

Example:

   #Category.pm
   package WebService::GData::Node::Category;
   use WebService::GData::Node;

   set_xml_meta(
        attributes=>['scheme','yt:term','label'],#default to []
        is_parent => 0, #default 1
        root_name => 'k', #default to ''
        tag_name  => 'category' # default to the package file name with the first letter in lower case
   );

   1;
   
   use WebService::GData::Node::Category();
   
   my $category = new WebService::GData::Node::Category('yt:term'=>'term');
      $category->yt_term('youtube term');
      
      "$category";#<k:category yt:term="youtube term"/>
	   
=back

=head2 IMPLEMENTED NODES

Many core nodes have already be implemented. You can look at their source directly to see their meta information.
Although you may use this class and subclasses to implement other tags, most of the time they will be wrapped in the Feed 
packages and the end user shall not interact directly with them.


For reference, below is a list of all the tags implemented so far with their meta information (when it overwrites the default settings).

    APP                         #app: namespace
        - Control
        - Draft
        - Edited
    Author
    Category                    #attributes=>scheme term label
    Content                     #attributes=>src type
    GD                          #gd: namespace
       - Comments
       - FeedLink               #attributes=>rel href countHint,is_parent=>0
       - Rating                 #attributes=>min max numRaters average value,is_parent=>0
    GeoRSS #georss: namespace
       - Where
    GML                         #gml: namespace
       - Point                  #tag_name=>'Point'
       - Pos
    Link                        #attributes=>rel type href
    Media                       #media: namespace
       - Category               #attributes=>scheme label
       - Content                #attributes=>url type medium isDefault expression duration yt:format,is_parent=>0
       - Credit                 #attributes=>role yt:type scheme
       - Description            #attributes=>type
       - Group
       - Keywords
       - Player                 #attributes=>url
       - Rating                 #attributes=>scheme country
       - Restriction            #attributes=>type relationship
       - Thumbnail              #attributes=>url height width time, is_parent=>0
       - Title                  #attributes=>type
    Name
    Summary
    Title
    Uri
       


=head2  CAVEATS

=over

=item * As the package push itself into your package when you use it, you must be aware when to change this behavior.

=item * All the methods installed in the package could conflict with a node name or its attributes.

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
