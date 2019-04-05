#!/usr/bin/env bash

# <bitbar.title>mpd-simple</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Murilo Pereira <murilo@murilopereira.com></bitbar.author>
# <bitbar.author.github>mpereira</bitbar.author.github>
# <bitbar.desc>MPD simple</bitbar.desc>
# <bitbar.image></bitbar.image>
# <bitbar.dependencies>mpd, mpc</bitbar.dependencies>

if ! pgrep mpd > /dev/null; then
  exit 0
fi

readonly mpc="/usr/local/bin/mpc"
readonly output="$(timeout 1 ${mpc} -f '%artist%\n%album%\n%title%' 2> /dev/null)"

if [[ "$(echo -e "${output}" | wc -l)" -eq 1 ]]; then
  exit 0
fi

readonly music_icon="♪"
readonly play_icon="▸"
readonly pause_icon="॥"
readonly previous_icon="⇽"
readonly next_icon="⇾"
readonly stop_icon="▪"
readonly size="12"
readonly color="#afc3ff"

if [[ -z $(echo "${output}" | awk 'NR==4' | grep playing) ]]; then
  state=paused
else
  state=playing
fi

if [[ "$state" = "playing" ]]; then
  state_icon="${music_icon}"
else
  state_icon="${pause_icon} "
fi

readonly artist=$(echo "${output}" | awk 'NR==1');
readonly album=$(echo "${output}" | awk 'NR==2');
readonly track=$(echo "${output}" | awk 'NR==3');

echo "${state_icon} ${artist} - ${track} | size=${size} color=${color}"
echo "---"
echo -n "Artist: "; echo "$artist"
echo "Album: $album"
echo "Track: $track"
if [ "$state" = "playing" ]; then
  echo "${pause_icon} Pause | bash='${mpc}' param1=pause terminal=false refresh=true"
  echo "${previous_icon} Previous | bash='${mpc}' param1='prev' terminal=false refresh=true"
  echo "${next_icon} Next | bash='${mpc}' param1='next' terminal=false refresh=true"
  echo "${stop_icon} Stop | bash='${mpc}' param1='stop' terminal=false refresh=true"
else
  echo "${play_icon} Play | bash='${mpc}' param1=play terminal=false refresh=true"
fi
