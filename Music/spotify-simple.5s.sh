#!/bin/bash

# <bitbar.title>Spotify</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Murilo Pereira <murilo@murilopereira.com></bitbar.author>
# <bitbar.author.github>mpereira</bitbar.author.github>
# <bitbar.desc>Display currently playing Spotify song. Play/pause, skip forward, skip backward.</bitbar.desc>
# <bitbar.image></bitbar.image>
# <bitbar.dependencies>Spotify.app</bitbar.dependencies>

# TODO: is it possible to get all of the necessary output running one command?

if [[ "$(osascript -e 'application "Spotify" is running')" = "false" ]]; then
  exit
fi

function tellspotify() {
  osascript -e "tell application \"Spotify\" to $1"
}

case "$1" in
  'activate' | 'playpause' | 'previous track' | 'next track')
    tellspotify "$1"
    exit
esac

readonly music_icon="♪"
readonly play_icon="▸"
readonly pause_icon="॥"
readonly previous_icon="⇽"
readonly next_icon="⇾"
readonly state=$(tellspotify 'player state as string')
readonly size="12"

readonly style="$(defaults read -g AppleInterfaceStyle 2> /dev/null)"

if [ "${style}" = "Dark" ]; then
  readonly color="#98f99d"
else
  readonly color="#006400"
fi

if [[ "${state}" = "playing" ]]; then
  state_icon="${music_icon}"
else
  state_icon="${pause_icon}"
fi

readonly artist=$(tellspotify 'artist of current track as string');
readonly album=$(tellspotify 'album of current track as string');
readonly track=$(tellspotify 'name of current track as string');

echo "${state_icon} ${artist} - ${track} | size=${size} color=${color}"
echo "---"
echo "Artist: $artist | color=#333333"
echo "Album: $album | color=#333333"
echo "Track: $track | color=#333333"
if [ "$state" = "playing" ]; then
  echo "${pause_icon} Pause | bash='$0' param1=playpause terminal=false refresh=true"
  echo "${previous_icon} Previous | bash='$0' param1='previous track' terminal=false refresh=true"
  echo "${next_icon} Next | bash='$0' param1='next track' terminal=false refresh=true"
else
  echo "${play_icon} Play | bash='$0' param1=playpause terminal=false refresh=true"
fi

echo '---'
echo "Open Spotify | bash='$0' param1=activate terminal=false"
