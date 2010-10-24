use Test::More tests => 1;
use WebService::GData::Node::Media::Content;

my $category = new WebService::GData::Node::Media::Content(
    url         => 'http://www.youtube.com',
    type        => "application/x-shockwave-flash",
    medium      => 'video',
    isDefault   => 'true',
    expression  => 'full',
    duration    => '0:43',
    'yt:format' => 6
);

$category->text('I am very funny.');


$category->yt_format(1);

ok(
    "$category" eq
q[<media:content url="http://www.youtube.com" type="application/x-shockwave-flash" medium="video" isDefault="true" expression="full" duration="0:43" yt:format="1"/>],
    'category object is properly output'
);

