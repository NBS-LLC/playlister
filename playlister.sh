#!/usr/bin/env bash

source playlister_lib.sh

playlist_id="$1"

client_id=$(get_env_var "PLAYLISTER_SPOTIFY_CLIENT_ID") || exit $?
client_secret=$(get_env_var "PLAYLISTER_SPOTIFY_CLIENT_SECRET") || exit $?
access_token=$(get_access_token $client_id $client_secret) || exit $?
playlist_data=$(get_playlist_data_by_id $access_token $playlist_id) || exit $?
tracks=$(parse_tracks_from_playlist_data "$playlist_data") || exit $?
audio_features=$(get_multiple_track_audio_features "$access_token" "$tracks") || exit $?
combined=$(combine_tracks_and_audio_features "$tracks" "$audio_features") || exit $?
simplified=$(simplify "$combined") || exit $?

to_csv "$simplified"
