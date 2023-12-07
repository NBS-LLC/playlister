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
    
    assert_equal "$(echo "$output" | jq -r '.[0].added_at')" "2023-02-01T02:35:30Z"
    assert_equal "$(echo "$output" | jq -r '.[0].id')" "1eb0mORiTlz0OLkH0NPb9Z"
    assert_equal "$(echo "$output" | jq -r '.[0].name')" "Opa Gäärd"

    assert_equal "$(echo "$output" | jq -r '.[22].added_at')" "2023-04-02T17:00:08Z"
    assert_equal "$(echo "$output" | jq -r '.[22].id')" "1nvHCuiZ0qErIJHnIiEZgA"
    assert_equal "$(echo "$output" | jq -r '.[22].name')" "Moonlight"

    assert_equal "$(echo "$output" | jq -r '.[47].added_at')" "2023-11-21T03:25:43Z"
    assert_equal "$(echo "$output" | jq -r '.[47].id')" "7biflzjN8c8v5mPuh71lXB"
    assert_equal "$(echo "$output" | jq -r '.[47].name')" "Togetherness"
}

@test "should parse track ids into csv" {
    tracks=$(cat tests/tracks_test_data.json)

    run parse_track_ids_as_csv "$tracks"
    assert_success
    assert_output "1eb0mORiTlz0OLkH0NPb9Z,0FFF1jhCgjVeazeorTOqcl,1nvHCuiZ0qErIJHnIiEZgA,7biflzjN8c8v5mPuh71lXB"
}

@test "should error if track length is greater than 100" {
    playlist_data=$(cat tests/playlist_test_data.json)
    tracks=$(parse_tracks_from_playlist_data "$playlist_data")
    large_track_list=$(echo "$tracks $tracks $tracks" | jq -s 'add')

    run get_multiple_track_audio_features "mock_access_token" "$large_track_list"
    assert_failure
}

@test "should get multiple track audio features" {
    client_id=$PLAYLISTER_SPOTIFY_CLIENT_ID
    client_secret=$PLAYLISTER_SPOTIFY_CLIENT_SECRET
    access_token=$(get_access_token "$client_id" "$client_secret")
    tracks=$(cat tests/tracks_test_data.json)

    run get_multiple_track_audio_features "$access_token" "$tracks"
    assert_success
    assert_equal "$(echo "$output" | jq length)" "4"

    assert_equal "$(echo "$output" | jq -r '.[0].tempo')" "99.98"
    assert_equal "$(echo "$output" | jq -r '.[1].tempo')" "139.97"
    assert_equal "$(echo "$output" | jq -r '.[2].tempo')" "129.005"
    assert_equal "$(echo "$output" | jq -r '.[3].tempo')" "126.021"
}

@test "should combine tracks and audio features in correct order" {
    tracks=$(cat tests/tracks_test_data.json)
    audio_features=$(cat tests/audio_features_test_data.json)

    run combine_tracks_and_audio_features "$tracks" "$audio_features"
    assert_success
    assert_equal "$(echo "$output" | jq length)" "4"

    assert_equal "$(echo "$output" | jq -r '.[0].added_at')" "2023-02-01T02:35:30Z"
    assert_equal "$(echo "$output" | jq -r '.[0].id')" "1eb0mORiTlz0OLkH0NPb9Z"
    assert_equal "$(echo "$output" | jq -r '.[0].name')" "Opa Gäärd"
    assert_equal "$(echo "$output" | jq -r '.[0].tempo')" "99.98"
    assert_equal "$(echo "$output" | jq -r '.[0].uri')" "spotify:track:1eb0mORiTlz0OLkH0NPb9Z"

    assert_equal "$(echo "$output" | jq -r '.[1].added_at')" "2023-02-21T07:09:50Z"
    assert_equal "$(echo "$output" | jq -r '.[1].id')" "0FFF1jhCgjVeazeorTOqcl"
    assert_equal "$(echo "$output" | jq -r '.[1].name')" "Infinite Gratitude"
    assert_equal "$(echo "$output" | jq -r '.[1].tempo')" "139.97"
    assert_equal "$(echo "$output" | jq -r '.[1].uri')" "spotify:track:0FFF1jhCgjVeazeorTOqcl"

    assert_equal "$(echo "$output" | jq -r '.[2].added_at')" "2023-04-02T17:00:08Z"
    assert_equal "$(echo "$output" | jq -r '.[2].id')" "1nvHCuiZ0qErIJHnIiEZgA"
    assert_equal "$(echo "$output" | jq -r '.[2].name')" "Moonlight"
    assert_equal "$(echo "$output" | jq -r '.[2].tempo')" "129.005"
    assert_equal "$(echo "$output" | jq -r '.[2].uri')" "spotify:track:1nvHCuiZ0qErIJHnIiEZgA"

    assert_equal "$(echo "$output" | jq -r '.[3].added_at')" "2023-11-21T03:25:43Z"
    assert_equal "$(echo "$output" | jq -r '.[3].id')" "7biflzjN8c8v5mPuh71lXB"
    assert_equal "$(echo "$output" | jq -r '.[3].name')" "Togetherness"
    assert_equal "$(echo "$output" | jq -r '.[3].tempo')" "126.021"
    assert_equal "$(echo "$output" | jq -r '.[3].uri')" "spotify:track:7biflzjN8c8v5mPuh71lXB"
}
