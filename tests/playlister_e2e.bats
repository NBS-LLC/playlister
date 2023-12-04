setup() {
    load '../vendor/bats-support/load'
    load '../vendor/bats-assert/load'
    load '../playlister.sh'

    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../:$PATH"
}

@test "should return extended track data" {
    run playlister.sh "2WagE1MGCatm33uHwfi5Hi"
    assert_success

    # TODO: Provide more meaningful asserts when app is fully implemented.
}

@test "should error if client id is missing" {
    unset PLAYLISTER_SPOTIFY_CLIENT_ID

    run playlister.sh "2WagE1MGCatm33uHwfi5Hi"
    assert_failure
}

@test "should error if client secret is missing" {
    unset PLAYLISTER_SPOTIFY_CLIENT_SECRET

    run playlister.sh "2WagE1MGCatm33uHwfi5Hi"
    assert_failure
}
