package WebService::GData::YouTube::Feed::Comment;
use base WebService::GData::Feed::Entry;
our $VERSION  = 0.01_02;

sub content {
    my ($this,$comment) = @_;
    $this->{_content}->text($comment) if $comment;
    $this->{_content}->text
}

1;