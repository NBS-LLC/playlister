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
    assert_equal "$(echo "$output" | jq length)" "48"
    
    assert_equal "$(echo "$output" | jq -r '.[0].name')" "Opa Gäärd"
    assert_equal "$(echo "$output" | jq -r '.[0].id')" "1eb0mORiTlz0OLkH0NPb9Z"

    assert_equal "$(echo "$output" | jq -r '.[22].name')" "Moonlight"
    assert_equal "$(echo "$output" | jq -r '.[22].id')" "1nvHCuiZ0qErIJHnIiEZgA"

    assert_equal "$(echo "$output" | jq -r '.[47].name')" "Togetherness"
    assert_equal "$(echo "$output" | jq -r '.[47].id')" "7biflzjN8c8v5mPuh71lXB"
}

# bats test_tags=bats:focus
@test "should error if track length is greater than 100" {
    playlist_data=$(cat tests/playlist_test_data.json)
    tracks=$(parse_tracks_from_playlist_data "$playlist_data")
    large_track_list=$(echo "$tracks $tracks $tracks" | jq -s 'add')

    run get_multiple_track_audio_features "mock_access_token" "$large_track_list"
    assert_failure
}
