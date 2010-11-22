package WebService::GData::Serialize::XML;
use WebService::GData;
use base 'WebService::GData';

our $VERSION = 0.01_02;


sub encode {
    my ( $this, $owner) = @_;

   my $tag =
        $this->namespace_prefix
      ? $this->namespace_prefix . ':' . $this->node_name
      : $this->node_name;
      

    my $is_root=( ($owner||{}) == $this );

    #the namespace prefix does not need to be specified
    #because we set the root namespace as being the default one
    $tag = $this->node_name if ($is_root);

    #if it is not the root but a children of the same type
    #don't need to specify the prefix either
    if ($owner && $this->namespace_prefix eq $owner->namespace_prefix ) {
        $tag = $this->node_name;
    }

    my $xml = qq[<$tag];

    #add the root as the default namespace
    $xml .= ' xmlns="' . $this->namespace_uri . '"' if ($is_root);
    
    #get all the attributes for this node and serialize them
    if ( @{ $this->attributes } > 0 ) {
        my @attrs = ();
        foreach my $attr ( @{ $this->attributes } ) {
            my $val = $this->{$attr};
            if ($val){
                push @attrs, qq[$attr="$val"];
                if(my($prefix)=$attr=~m/(.+?):/){

                    if(ref $this->extra_namespaces eq 'HASH' && $this->extra_namespaces->{$prefix}){
                        $owner->namespaces->{ 'xmlns:' . $prefix . '="'. $this->extra_namespaces->{$prefix}. '"' } = 1
                            if ($owner && $prefix ne $owner->namespace_prefix ); 
                    } 
                }
            }
        }
        $xml .= ' ' . join( ' ', @attrs ) if ( @attrs > 0 );
    }

    if ( $this->is_parent ) {

        my $xmlchild   = "";
        
        #append the text first
        $xmlchild .= $this->{text} if ( $this->{text} );
        
        #serialize all the children
        foreach my $child (@{$this->child}) {
            if($child->isa('WebService::GData::Collection')) {
                $xmlchild .= encode($_,$owner) for(@$child);
            }
            else {
                $xmlchild .= encode($child,$owner);                
            }
            
            #we append the namespace prefix and uri to the root
            __add_namespace_uri($child,$owner) if ($owner);
 
        }
        
        if($is_root) {
            #gather all the namespaces
            my @namespaces = keys %{$owner->namespaces};
            $xml .= " " . join( " ", @namespaces ) if ( @namespaces > 0 );
        }
        
        #close the root tag
        $xml .= '>';
        
        #append the children and close the container
        $xml .= $xmlchild . qq[</$tag>];
    }
    else {
        $xml .= '/>';
    }
    return $xml;
}

sub __add_namespace_uri {
    my ($child,$owner) = @_;
    
    my $namespaces= $owner->namespaces;
    
    #Node
    my $namespace_prefix = $child->namespace_prefix;
    my $uri       = $child->namespace_uri;

    #Collection is an array of identic nodes, so look for the first node only
    if ( $child->isa('WebService::GData::Collection') ) {
         $namespace_prefix = $child->[0]->namespace_prefix;
         $uri       = $child->[0]->namespace_uri;
    }
    #if this child is an Entity, look for the root
    if ( $child->isa('WebService::GData::Node::AbstractEntity') ) {
          $namespace_prefix = $child->_entity->namespace_prefix;
          $uri       = $child->_entity->namespace_uri;
    }

    $namespaces->{ 'xmlns'. ( $namespace_prefix ? ':' . $namespace_prefix : "" ) . '="'. $uri. '"' } = 1
       if ( $namespace_prefix ne $owner->namespace_prefix );    
    
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
        namespace_prefix => 'k', #default to ''
        tag_name  => 'category' # default to the package file name with the first letter in lower case
   );

   1;

    #user code:
	use WebService::GData::Node::Name();  #avoid to inherit from it by not importing
	use WebService::GData::Node::Author();
	use WebService::GData::Node::Category();
		
    my $author   = new WebService::GData::Node::Author();
    my $name     = new WebService::GData::Node::Name(text=>'john doe');
    my $category = new WebService::GData::Node::Category(scheme=>'author','yt:term'=>'Author');
    
    #or coming from a json feed:
    my $category = new WebService::GData::Node::Category({scheme=>'author','yt$term'=>'Author'});
    
    
    
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

=head2 AUTOLOAD

=head3 __set/__get

=over

The attributes setter/getters and the text method are generated on the fly.

=item * you can use either hyphen base notation or camelCase notation.

=item * Attributes containing namespaces can be accessed by replacing ':' with
'_'. yt:format attribute can be set/get via the yt_format method. You should use the qualified attribute when setting it via the constructor.
Therefore, new Node(yt_format=>1) will not work but new Node('yt:format'=>1) and new Node({'yt$format'=>1}) will work.

Example:

    use WebService::GData::Node::FeedLink;
    
    my $feedlink = new WebService::GData::Node::FeedLink($link);
    
    $feedlink->countHint;
    
    #or
    $feedlink->count_hint;

=head2 METHODS

=head3 child

=over

Set an other node child of the instance. It returns the instance so you can chain the calls.
You can not set the instance as a child of itself.
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

=head3 swap

=over

This method will put a new instance instead of an existing child.

B<Parameters>

=over

=item C<oldchild::WebService::GData::Node|WebService::GData::Collection> - the node to remove in the children collection

=item C<newchild::WebService::GData::Node|WebService::GData::Collection> - the node to put instead

=back

B<Returns> 

=over 

=item Cnone>

=back

Example:

    my $author   = new WebService::GData::Node::Author();
    my $name     = new WebService::GData::Node::Name(text=>'john doe');
    my $category = new WebService::GData::Node::Category(scheme=>'author',term=>'Author');
    
    $author->child($name)->child($category);
    
    my $newname = new WebService::GData::Node::Name(text=>'billy doe');
    $author->swap($name,$newname);
    
	   
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

=head3 namespace_prefix

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

=item B<namespace_prefix:Scalar> - the namespace name of the tag, ie, yt:, media: ...

=item B<tag_name:Scalar>  - the name of the tag it sefl, ie, category, author...

=item B<attributes:ArrayRef> - a list of the node attributes, ie, src, scheme... Default: []

=item B<is_parent:Int> - specify if the node can accept children, including text node. Default: 1 (true),0 if not.


=back

B<Returns> install the methods in the package.


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
        namespace_prefix => 'k', #default to ''
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
