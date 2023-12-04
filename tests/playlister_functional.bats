setup() {
    load '../vendor/bats-support/load'
    load '../vendor/bats-assert/load'
    load '../playlister.sh'

    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../:$PATH"
}

@test "should get playlist data by id" {
    client_id=$PLAYLISTER_SPOTIFY_CLIENT_ID
    client_secret=$PLAYLISTER_SPOTIFY_CLIENT_SECRET
    access_token=$(get_access_token "$client_id" "$client_secret")

    run get_playlist_data_by_id "$access_token" "2WagE1MGCatm33uHwfi5Hi"
    assert_success
    assert_output --partial '"uri": "spotify:playlist:2WagE1MGCatm33uHwfi5Hi"'
}

@test "should parse tracks from playlist data" {
    playlist_data=$(cat tests/playlist_test_data.json)
    
    run parse_tracks_from_playlist_data "$playlist_data"
    assert_success
    assert [ $(echo "$output" | wc -l) -eq 48 ]
    assert_line --index 0 'https://api.spotify.com/v1/tracks/1eb0mORiTlz0OLkH0NPb9Z'
    assert_line --index 22 'https://api.spotify.com/v1/tracks/1nvHCuiZ0qErIJHnIiEZgA'
    assert_line --index 47 'https://api.spotify.com/v1/tracks/7biflzjN8c8v5mPuh71lXB'
}