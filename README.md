# playlister

A command line tool for retrieving a playlist's track audio features as a csv.

For example:

```shell
> ./playlister.sh 2WagE1MGCatm33uHwfi5Hi

"acousticness","added_at","danceability","duration_ms","energy","id","instrumentalness","key","liveness","loudness","mode","name","speechiness","tempo","time_signature","valence"
0.434,"2023-02-01T02:35:30Z",0.641,423598,0.466,"1eb0mORiTlz0OLkH0NPb9Z",0.943,3,0.0972,-13.505,0,"Opa Gäärd",0.0403,99.98,4,0.352
# multiple tracks omitted for brevity
0.00721,"2023-10-03T02:50:34Z",0.807,417049,0.658,"2m6iDdv9RDLnoQiVo8bu7N",0.891,0,0.0672,-14.091,1,"Spinifex Drum",0.0444,121.997,4,0.557
0.0244,"2023-10-06T16:05:59Z",0.77,297802,0.639,"6qLDqEm4xmS8GvJKHl5Qx0",0.844,2,0.118,-11.572,1,"Hidden Garden",0.0609,99.995,4,0.276
0.00355,"2023-11-21T03:25:43Z",0.712,220952,0.867,"7biflzjN8c8v5mPuh71lXB",0.0117,10,0.0349,-5.619,1,"Togetherness",0.0785,126.021,4,0.774
```

## Prerequisites

* bash
* curl
* jq

## Installation

```shell
> git clone https://github.com/NBS-LLC/playlister

```

## Configuration

The following environment variables must be set:

- PLAYLISTER_SPOTIFY_CLIENT_ID
- PLAYLISTER_SPOTIFY_CLIENT_SECRET

See Spotify's Web API [getting started](https://developer.spotify.com/documentation/web-api/tutorials/getting-started) guide for details on obtaining a client id and secret.

## Usage

```shell
> ./playlister.sh playlist_id
```

A playlist_id can be retrieved by using Spotify's Web Player and clicking a public playlist.

The playlist_id is the last path parameter, for example: https://open.spotify.com/playlist/2WagE1MGCatm33uHwfi5Hi

```shell
> ./playlister.sh 2WagE1MGCatm33uHwfi5Hi
```

## Testing

When contributing to the project automated tests can be executed:

```shell
> ./playlister_tests.sh
```
