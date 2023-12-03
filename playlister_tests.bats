#!./vendor/bats-core/bin/bats

setup() {
    load 'vendor/bats-support/load'
    load 'vendor/bats-assert/load'
}

@test "should return playlist data" {
    run ./playlister.sh "2WagE1MGCatm33uHwfi5Hi"
    assert_success
    assert_output --partial '"uri": "spotify:playlist:2WagE1MGCatm33uHwfi5Hi"'
}

@test "should error if client id is missing" {
    unset PLAYLISTER_SPOTIFY_CLIENT_ID

    run ./playlister.sh "2WagE1MGCatm33uHwfi5Hi"
    assert_failure
}

@test "should error if client secret is missing" {
    unset PLAYLISTER_SPOTIFY_CLIENT_SECRET

    run ./playlister.sh "2WagE1MGCatm33uHwfi5Hi"
    assert_failure
}
