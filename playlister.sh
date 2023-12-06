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

    echo "$playlist_data" | jq '.tracks.items[].track | { "name": .name, "id": .id }' | jq -s '.'
}

parse_track_ids_as_csv() {
    local tracks=$1

    echo "$tracks" | jq '.[].id' | jq -r -s 'join(",")'
}

get_multiple_track_audio_features() {
    local access_token=$1
    local tracks=$2

    if [[ $(echo "$tracks" | jq length) -gt 100 ]]; then
        echo "Error: Processing more than 100 tracks is not supported." >&2
        exit 1
    fi
}

###############################################################################
### MAIN
###############################################################################

playlist_id="$1"

client_id=$(get_env_var "PLAYLISTER_SPOTIFY_CLIENT_ID") || exit $?
client_secret=$(get_env_var "PLAYLISTER_SPOTIFY_CLIENT_SECRET") || exit $?
access_token=$(get_access_token $client_id $client_secret) || exit $?
playlist_data=$(get_playlist_data_by_id $access_token $playlist_id) || exit $?

parse_tracks_from_playlist_data "$playlist_data"
