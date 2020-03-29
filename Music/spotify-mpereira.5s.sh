#!/usr/bin/env bash

# <bitbar.title>Spotify</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Murilo Pereira <murilo@murilopereira.com></bitbar.author>
# <bitbar.author.github>mpereira</bitbar.author.github>
# <bitbar.desc>Display currently playing Spotify song. Play/pause, skip forward, skip backward.</bitbar.desc>
# <bitbar.image></bitbar.image>
# <bitbar.dependencies>Spotify.app</bitbar.dependencies>

# TODO: is it possible to get all of the necessary output running one command?

readonly state_directory="/tmp/bitbar"
readonly state_file="${state_directory}/$(basename "${0}").state"

mkdir -p "${state_directory}"

readonly mpd_state_file="$(find ${state_directory} -maxdepth 1 -type f -print -quit -iname "mpd*" 2>/dev/null)"
readonly mpd_state="$(test -f "${mpd_state_file}" && cat "${mpd_state_file}")"

if [[ "$(osascript -e 'application "Spotify" is running')" = "false" ]]; then
  rm -f "${state_file}"
  exit 0
fi

function tell_spotify {
  osascript -e "tell application \"Spotify\" to ${1}"
}

case "${1}" in
  "activate" | "playpause" | "previous track" | "next track")
    tell_spotify "${1}"
    exit 0
esac

readonly music_icon="♪"
readonly play_icon="▸"
readonly pause_icon="॥"
readonly previous_icon="⇽"
readonly next_icon="⇾"
readonly size="12"

readonly player_state="$(tell_spotify "player state as string")"

echo "${player_state}" > "${state_file}"

if [[ "${player_state}" = "paused" ]] && [[ "${mpd_state}" = "playing" ]]; then
  exit 0
fi

readonly style="$(defaults read -g AppleInterfaceStyle 2> /dev/null)"

if [ "${style}" = "Dark" ]; then
  readonly color="#98f99d"
else
  readonly color="#006400"
fi

if [[ "${player_state}" = "playing" ]]; then
  state_icon="${music_icon}"
else
  state_icon="${pause_icon}"
fi

readonly artist=$(tell_spotify 'artist of current track as string');
readonly album=$(tell_spotify 'album of current track as string');
readonly track=$(tell_spotify 'name of current track as string');

echo "${state_icon} ${artist} - ${track} | size=${size} color=${color}"
echo "---"
echo "Artist: $artist | color=#333333"
echo "Album: $album | color=#333333"
echo "Track: $track | color=#333333"
if [ "$player_state" = "playing" ]; then
  echo "${pause_icon} Pause | bash='$0' param1=playpause terminal=false refresh=true"
  echo "${previous_icon} Previous | bash='$0' param1='previous track' terminal=false refresh=true"
  echo "${next_icon} Next | bash='$0' param1='next track' terminal=false refresh=true"
else
  echo "${play_icon} Play | bash='$0' param1=playpause terminal=false refresh=true"
fi

echo '---'
echo "Open Spotify | bash='$0' param1=activate terminal=false"
