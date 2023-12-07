#!/usr/bin/env bash

get_env_var() {
    local var_name=$1
    local var_value=${!var_name}

    if [[ -z "${var_value}" ]]; then
        echo "Error: Environment variable '${var_name}' is not set." >&2
        exit 1
    else
        echo "${var_value}"
    fi
}

get_access_token() {
    local client_id=$1
    local client_secret=$2

    curl -s -X POST "https://accounts.spotify.com/api/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials&client_id=${client_id}&client_secret=${client_secret}" | jq -r '.access_token'
}

get_playlist_data_by_id() {
    local access_token=$1
    local playlist_id=$2

    curl -s --request GET \
        --url "https://api.spotify.com/v1/playlists/${playlist_id}" \
        --header "Authorization: Bearer ${access_token}" | jq '.'
}

parse_tracks_from_playlist_data() {
    local playlist_data=$1

    echo "$playlist_data" | jq '.tracks.items[] | { "added_at": .added_at, "id": .track.id, "name": .track.name }' | jq -s '.'
}

parse_track_ids_as_csv() {
    local tracks=$1

    echo "$tracks" | jq 'sort_by(.added_at) | .[].id' | jq -r -s 'join(",")'
}

get_multiple_track_audio_features() {
    local access_token=$1
    local tracks=$2

    if [[ $(echo "$tracks" | jq length) -gt 100 ]]; then
        echo "Error: Processing more than 100 tracks is not supported." >&2
        exit 1
    fi

    local track_ids=$(parse_track_ids_as_csv "$tracks") || exit $?

    curl -s --request GET \
        --url "https://api.spotify.com/v1/audio-features?ids=${track_ids}" \
        --header "Authorization: Bearer ${access_token}" | jq '.audio_features'
}

combine_tracks_and_audio_features() {
    local tracks=$1
    local audio_features=$2

    echo $tracks $audio_features | jq -s 'add | group_by(.id) | map(add) | sort_by(.added_at)'
}

simplify() {
    local combined=$1

    echo $combined | jq 'del(.[]["type", "uri", "track_href", "analysis_url"])'
}

###############################################################################
### MAIN
###############################################################################

playlist_id="$1"

client_id=$(get_env_var "PLAYLISTER_SPOTIFY_CLIENT_ID") || exit $?
client_secret=$(get_env_var "PLAYLISTER_SPOTIFY_CLIENT_SECRET") || exit $?
access_token=$(get_access_token $client_id $client_secret) || exit $?
playlist_data=$(get_playlist_data_by_id $access_token $playlist_id) || exit $?
tracks=$(parse_tracks_from_playlist_data "$playlist_data") || exit $?
audio_features=$(get_multiple_track_audio_features "$access_token" "$tracks") || exit $?
combined=$(combine_tracks_and_audio_features "$tracks" "$audio_features") || exit $?

simplify "$combined"
