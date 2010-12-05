use Test::More tests => 33;
use WebService::GData::YouTube::Feed::Video;
use t::JSONResponse;
use JSON;

my $entry = new WebService::GData::YouTube::Feed::Video(
    from_json($JSONResponse::CONTENTS)->{feed}->{entry}->[0] );

ok( $entry->title eq "Young Turks Episode 10-07-09", "Title properly set." );

$entry->title("new title");

ok( $entry->title eq 'new title', "Title properly changed." );

ok( $entry->etag eq "W/\"A0QDSX47eCp7ImA9Wx5RGUw.\"", "etag properly set." );

ok( $entry->updated eq "2010-08-27T14:29:38.000Z", "updated properly set." );

ok( $entry->published eq "2009-10-08T04:39:24.000Z",
    "published properly set." );

ok( $entry->id eq "tag:youtube.com,2008:video:qWAY3YvHqLE",
    'id properly set.' );

ok( @{ $entry->links } == 5, "links properly set." );

ok( $entry->links->[0]->rel eq 'alternate', "first link properly set." );

ok(
    $entry->links->rel('#video.responses')->[0]->href eq
q[http://gdata.youtube.com/feeds/api/videos/qWAY3YvHqLE/responses?client=ytapi-google-jsdemo],
    'searching via the nodes return the proper result.'
);
ok(
    $entry->links->[0] == $entry->links->[0],
    'collection can be accessed as an array ref.'
);

my $i = 0;
foreach my $link ( @{ $entry->links } ) {

    ok( $link == $entry->links->[$i],
        'collection can loop over the array ref ' . $i );
    $i++;
}

ok( $entry->video_id eq "qWAY3YvHqLE", 'video_id is properly set.' );

$entry->video_id('id set');

ok( $entry->video_id eq 'id set', 'video_id is properly changed.' );

ok( $entry->favorite_count eq '31', 'favorite_count is properly set.' );

ok( $entry->view_count eq '13067', 'view_count is properly set.' );

ok( $entry->duration eq '3290', 'duration is properly set.' );

ok( $entry->uploaded eq "2009-10-08T04:39:24.000Z",
    'uploaded is properly set.' );

ok(
    $entry->keywords eq
"the, young, turks, cenk, uygur, ana, kasparian, rush, limbaugh, rams, gohmert, sotomayor, shep, smith, obama, guns, rights, delay, cops, be, commentary, analysis, political, commercial, documentary, news, grassroots, outreach",
    'keywords are properly set.'
);

ok(
    $entry->description eq
"Watch more at www.theyoungturks.com Follow us on Twitter. http Check Out TYT Interviews www.youtube.com",
    'description is properly set.'
);

ok( @{ $entry->access_control } == 7, 'access control is properly set.' );

ok( @{ $entry->thumbnails } == 5, 'number of thumbnails is right.' );

ok( @{ $entry->content } == 3,    'number of content is right.' );

ok( @{ $entry->category } == 1,   'number of category is properly set.' );

ok( @{ $entry->author } == 1,   'number of author is properly set.' );

ok( $entry->author->[0]->name eq "TheYoungTurks", 'author name properly set.' );

ok(
    $entry->author->[0]->uri eq
      "http://gdata.youtube.com/feeds/api/users/theyoungturks",
    'author uri properly set.'
);

ok( $entry->location eq "25.482952117919922 32.34375",
    'location is properly set.' );

ok(
    $entry->media_player eq
"http://www.youtube.com/watch?v=qWAY3YvHqLE&feature=youtube_gdata_player",
    "media player properly set."
);


ok(
    $entry->comments eq
"http://gdata.youtube.com/feeds/api/videos/qWAY3YvHqLE/comments?client=ytapi-google-jsdemo",
    'comments url properly set.'
);


