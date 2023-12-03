# playlister

A command line app for retrieving extended playlist song details

## Installation

Submodules are used, so be sure to:

```shell
> git clone --recurse-submodules https://github.com/NBS-LLC/playlister

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
