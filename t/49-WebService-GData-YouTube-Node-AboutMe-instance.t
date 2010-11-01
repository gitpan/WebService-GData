use Test::More tests => 1;
use WebService::GData::YouTube::YT::AboutMe;

my $aboutme = new WebService::GData::YouTube::YT::AboutMe();
    
   $aboutme->text('I am very funny.');

ok($aboutme->serialize eq q[<yt:aboutMe>I am very funny.</yt:aboutMe>],'AboutMe is properly set.');


