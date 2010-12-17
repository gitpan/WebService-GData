package WebService::GData::Serialize::XML;
use WebService::GData;
use base 'WebService::GData';

our $VERSION = 0.01_03;


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
				$val =_to_html_entities($val);
                push @attrs,qq[$attr="$val"]; 
            }

            #we have an attribute with a prefix, yt:format...
            #let's append the meta info about this namespace
            if(my($prefix)=$attr=~m/(.+?):/){

                if(ref $this->extra_namespaces eq 'HASH' && $this->extra_namespaces->{$prefix}){
                    $owner->namespaces->{ 'xmlns:' . $prefix . '="'. $this->extra_namespaces->{$prefix}. '"' } = 1
                        if ($owner && $prefix ne $owner->namespace_prefix ); 
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
my %entitymap = (
 	'&'=> '&amp;',  
	'>'=> '&gt;',  
	'<'=> '&lt;', 
 	'"'=> '&quot;',  
 	"'"=> '&apos;' 
);

my $char = '['.join('',(keys %entitymap)).']';

sub _to_html_entities {
	my $val = shift;
	$val=~s/($char)/$entitymap{$1}/ge;
	return $val;
}



"The earth is blue like an orange.";

__END__

