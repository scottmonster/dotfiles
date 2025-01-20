#!/usr/bin/env bash
# the purpose of this script is ONLY to get us to the point where lua is installed

PACKAGE_MANAGERS=(apt nala dnf pacman zypper emerge apk brew port choco winget scoop)

install_lua() {
  local package_manager
  echo "attempting to install lua"
  if [ -n "$1" ]; then
    package_manager="$1"
  else
    echo "No package manager specified. Exiting..."
    exit 1
  fi

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

  # then we need to call the lua script
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

if [ "${#found_managers[@]}" -gt 1 ]; then
  echo "Multiple package managers found: ${found_managers[*]}"
  echo "Please enter a number between 1 and $((${#found_managers[@]} + 1))"
  package_manager=$(select_package_manager "${found_managers[@]}")
  if [ -z "$package_manager" ]; then
    echo "No package manager selected. Exiting..."
    exit 1
  fi
fi

# just make sure we havent already set package manager somewhere else and verify we only found 1
if [ -z "$package_manager" ] && [ "${#found_managers[@]}" -eq 1 ]; then
  package_manager=${found_managers[0]}
fi


install_lua "$package_manager"
