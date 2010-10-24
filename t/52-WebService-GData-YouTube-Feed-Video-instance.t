use Test::More tests => 14;
use WebService::GData::YouTube::Feed::Video;
use t::JSONResponse;
use JSON;

my $entry = new WebService::GData::YouTube::Feed::Video( from_json($JSONResponse::CONTENTS)->{feed}->{entry}->[0] );


ok( $entry->title eq "Young Turks Episode 10-07-09", "Title properly set." );

$entry->title("new title");

ok( $entry->title eq 'new title', "Title properly set." );

ok( $entry->etag eq "W/\"A0QDSX47eCp7ImA9Wx5RGUw.\"", "etag properly set." );

ok( $entry->updated eq "2010-08-27T14:29:38.000Z", "updated properly set." );

ok( $entry->published eq "2009-10-08T04:39:24.000Z",
    "published properly set." );

ok( @{ $entry->links } == 5, "links properly set." );

ok( $entry->links->[0]->rel eq 'alternate', "first link properly set." );

foreach my $func (
    (
        qw(total_items total_results start_index items_per_page previous_link next_link entry)
    )
  )
{

    ok(
        $entry->$func->isa('WebService::GData::Feed::Entry'),
        "disabled functions returned the instance properly."
    );
}





