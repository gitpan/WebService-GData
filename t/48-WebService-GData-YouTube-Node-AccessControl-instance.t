use Test::More tests => 1;
use WebService::GData::YouTube::YT::AccessControl;

my $accessControl = new WebService::GData::YouTube::YT::AccessControl();
    
   $accessControl->action('comment');
   $accessControl->permission('allowed');

ok($accessControl->serialize eq q[<yt:accessControl action="comment" permission="allowed"/>],'$accessControl is properly set.');
