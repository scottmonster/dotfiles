#!/usr/bin/env bash
# the purpose of this script is ONLY to get us to the point where lua is installed

# uncommit this line if you would like to prefer apt over nala. this only has an effect if apt and nala are the only package managers installed
# PREFER_APT=1

PACKAGE_MANAGERS=(apt nala dnf pacman zypper emerge apk brew port choco winget scoop)

install_lua() {
  local package_manager
  if [ -n "$1" ]; then
    package_manager="$1"
  else
    echo "No package manager specified. Exiting..."
    exit 1
  fi

  echo "attempting to install lua with $package_manager"
  case "$package_manager" in
  apt)
    sudo DEBIAN_FRONTEND=noninteractive apt install -y lua5.1
    ;;
  nala)
    sudo DEBIAN_FRONTEND=noninteractive nala install -y lua5.1
    ;;
  dnf)
    ask_for_help "sudo dnf install -y lua5.1"
    ;;
  pacman)
    ask_for_help "sudo pacman -S --noconfirm lua51"
    ;;
  zypper)
    ask_for_help "sudo zypper install -y lua51"
    ;;
  emerge)
    ask_for_help "sudo emerge --quiet-build=y --noreplace dev-lang/lua:5.1"
    ;;
  apk)
    ask_for_help "sudo apk add lua5.1"
    ;;
  brew)
    ask_for_help "NONINTERACTIVE=1 brew install lua@5.1"
    ;;
  port)
    ask_for_help "sudo port -N install lua51"
    ;;
  choco)
    ask_for_help "choco install -y lua51"
    ;;
  winget)
    ask_for_help "winget install -e --id=Lua --version 5.1.5.52 --silent"
    ;;
  scoop)
    ask_for_help "scoop install lua51"
    ;;
  *)
    echo "Unknown package manager: $package_manager"
    exit 1
    ;;
  esac

  lua_cmd="$(command -v lua)"
  if [ -z "$lua_cmd" ]; then
    echo "unable to properly install lua"
    exit 1
  fi

  # Debug the captured version
  lua_version="$($lua_cmd -v 2>&1 | tr -d '\n')"
  

  if [[ "$lua_version" != *"5.1"* ]]; then
      echo "Lua version is not 5.1"
      echo "Found version: $lua_version"
      exit 1
  fi

}

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo."
  exit 1
fi


# if we are on mac and homebrew isn't installed
if [ "$(uname)" = "Darwin" ] && ! command -v brew >/dev/null 2>&1; then
  bash_cmd="$(command -v bash)"
  $bash_cmd -c "NONINTERACTIVE=1; $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # ... don't we have to do something with path afterwards?... i can't rememeber
fi

select_package_manager() {
  local package_managers=("$@")
  local selection
  select pm in "${package_managers[@]}" "Quit"; do
    case $REPLY in
    '' | *[!0-9]*)
      echo "Please enter a number between 1 and $((${#package_managers[@]} + 1))"
      continue
      ;;
    $((${#package_managers[@]} + 1)))
      echo "Exiting..."
      exit 0
      ;;
    *)
      if [ "$REPLY" -le "${#package_managers[@]}" ]; then
        selection=${package_managers[$REPLY - 1]}
        # echo "Selected package manager: $selection"
        # echo "$selection"
        printf "%s" "$selection"
        break
      else
        echo "Invalid selection"
        continue
      fi
      ;;
    esac
  done
}

ask_for_help() {
  echo "I haven't had the chance to test using $package_manager"
  echo "So I'm not 100% sure how to install lua 5.1"
  echo "If you could let me know I would greatly appreciate it"
  echo "I think it is:"
  echo "$1"
  echo "If you know what you are doing, feel free to make the changes"
}

found_managers=()
for pm in "${PACKAGE_MANAGERS[@]}"; do
  if command -v "$pm" >/dev/null 2>&1; then
    found_managers+=("$pm")
  fi
done

if [ "${#found_managers[@]}" -lt 1 ]; then
  echo "No package managers found. Exiting..."
  exit 1
fi

# if [[ " ${found_managers[*]} " == *" apt "* && " ${found_managers[*]} " == *" nala "* && "${#found_managers[@]}" -eq 2 ]]; then
#     echo "checking for PREFER_APT"
#     found_managers=()
#     if [ "${PREFER_APT:-0}" -eq 1 ]; then
#       found_managers=("apt")
#     else
#       found_managers=("nala")
#     fi
#     echo "set to ${found_managers[*]}"
# fi

if [ "${#found_managers[@]}" -gt 1 ]; then

  # Save current terminal settings
  saved_settings=$(stty -g 2>/dev/null || true)
  
  # Attempt to make terminal interactive
  exec < /dev/tty 2>/dev/null || true

  echo "Multiple package managers found: ${found_managers[*]}"
  echo "Please enter a number between 1 and $((${#found_managers[@]} + 1))"
  package_manager=$(select_package_manager "${found_managers[@]}")

  # Restore original settings
  if [ -n "$saved_settings" ]; then
    stty "$saved_settings" 2>/dev/null || true
  fi

  if [ -z "$package_manager" ]; then
    echo "No package manager selected. Exiting..."
    exit 1
  fi
fi

# just make sure we havent already set package manager somewhere else and verify we only found 1
if [ -z "$package_manager" ] && [ "${#found_managers[@]}" -eq 1 ]; then
  package_manager=${found_managers[0]}
fi


# this actually isn't right because we dont check lua version
# im only concerned with new installs and lua won't be installed so I'm just rolling with it for now
lua_cmd="$(command -v lua)"
if [ -z "$lua_cmd" ]; then
  install_lua "$package_manager"
fi
# ^^^ install_lua sets the lua_cmd variable or exits if it isn't there or wrong version
echo "lua is installed"

# https://raw.githubusercontent.com/scottmonster/dotfiles/refs/heads/master/bin/do_werk.lua
curl_cmd="$(command -v curl)"
if [ -z "$curl_cmd" ]; then
  echo "nope"
  exit 1
fi
echo "got a curl command at $curl_cmd"

# we may need to change this for different environments... im not sure
curl_args="-s"

lua_script_url="https://raw.githubusercontent.com/scottmonster/dotfiles/refs/heads/master/bin/do_werk.lua"
$curl_cmd $curl_args "$lua_script_url" | $lua_cmd

