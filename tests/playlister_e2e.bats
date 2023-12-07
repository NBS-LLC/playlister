setup() {
    load '../vendor/bats-support/load'
    load '../vendor/bats-assert/load'

    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../:$PATH"
}

@test "should list a playlist's track audio features as csv" {
    run playlister.sh "2WagE1MGCatm33uHwfi5Hi"
    assert_success
    assert [ $(echo "$output" | wc -l) -ge 49 ]

    assert_line --index 0 '"acousticness","added_at","danceability","duration_ms","energy","id","instrumentalness","key","liveness","loudness","mode","name","speechiness","tempo","time_signature","valence"'
    assert_line --index 1 '0.434,"2023-02-01T02:35:30Z",0.641,423598,0.466,"1eb0mORiTlz0OLkH0NPb9Z",0.943,3,0.0972,-13.505,0,"Opa Gäärd",0.0403,99.98,4,0.352'
    assert_line --index 23 '0.00328,"2023-04-02T17:00:08Z",0.635,249767,0.889,"1nvHCuiZ0qErIJHnIiEZgA",0.38,2,0.108,-4.267,0,"Moonlight",0.0431,129.005,3,0.0539'
    assert_line --index 48 '0.00355,"2023-11-21T03:25:43Z",0.712,220952,0.867,"7biflzjN8c8v5mPuh71lXB",0.0117,10,0.0349,-5.619,1,"Togetherness",0.0785,126.021,4,0.774'
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
