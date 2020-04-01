#!/usr/bin/env bash

# <bitbar.title>mpd-simple</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Murilo Pereira <murilo@murilopereira.com></bitbar.author>
# <bitbar.author.github>mpereira</bitbar.author.github>
# <bitbar.desc>MPD simple</bitbar.desc>
# <bitbar.image></bitbar.image>
# <bitbar.dependencies>mpd, mpc</bitbar.dependencies>

if ! pgrep "^mpd$" > /dev/null; then
  exit 0
fi

readonly state_directory="/tmp/bitbar"
readonly state_file="${state_directory}/$(basename "${0}").state"

mkdir -p "${state_directory}"

readonly spotify_state_file="$(find ${state_directory} -maxdepth 1 -type f -iname "spotify*" -print -quit 2>/dev/null)"
readonly spotify_state="$(test -f "${spotify_state_file}" && cat "${spotify_state_file}")"

readonly mpc="/usr/local/bin/mpc"
# I used to have `timeout` here, but it seems to break the command for some
# reason.
readonly output="$(${mpc} -f '%artist%\n%album%\n%title%' 2> /dev/null)"

if [[ "$(echo -e "${output}" | wc -l)" -eq 1 ]]; then
  rm -f "${state_file}"
  exit 0
fi

readonly music_icon="♪"
readonly play_icon="▸"
readonly pause_icon="॥"
readonly previous_icon="⇽"
readonly next_icon="⇾"
readonly stop_icon="▪"
readonly size="12"

readonly style="$(defaults read -g AppleInterfaceStyle 2> /dev/null)"

if [ "${style}" = "Dark" ]; then
  readonly color="#98f99d"
else
  readonly color="#006400"
fi

function shorten {
  length=20
  ellipsis="…"
  read -r string
  echo "${string}" | sed -E "s/(.{${length}}).*$/\\1${ellipsis}/"
}

if ! echo "${output}" | awk 'NR==4' | grep -q playing; then
  player_state="paused"
else
  player_state="playing"
fi

echo "${player_state}" > "${state_file}"

if [[ "${spotify_state}" = "playing" ]] && [[ "${player_state}" = "paused" ]]; then
  exit 0
fi

if [[ "$player_state" = "playing" ]]; then
  player_state_icon="${music_icon}"
else
  player_state_icon="${pause_icon} "
fi

readonly artist=$(echo "${output}" | awk 'NR==1');
readonly album=$(echo "${output}" | awk 'NR==2');
readonly track=$(echo "${output}" | awk 'NR==3');

readonly shortened_artist=$(echo "${artist}" | shorten);
readonly shortened_album=$(echo "${album}" | shorten);
readonly shortened_track=$(echo "${track}" | shorten);

echo "${player_state_icon} ${shortened_artist} - ${shortened_track} | size=${size} color=${color}"
echo "---"
echo -n "Artist: "; echo "$artist"
echo "Album: $album"
echo "Track: $track"
if [ "$player_state" = "playing" ]; then
  echo "${pause_icon} Pause | bash='${mpc}' param1=pause terminal=false refresh=true"
  echo "${previous_icon} Previous | bash='${mpc}' param1='prev' terminal=false refresh=true"
  echo "${next_icon} Next | bash='${mpc}' param1='next' terminal=false refresh=true"
  echo "${stop_icon} Stop | bash='${mpc}' param1='stop' terminal=false refresh=true"
else
  echo "${play_icon} Play | bash='${mpc}' param1=play terminal=false refresh=true"
fi
