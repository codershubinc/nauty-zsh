# Enable prompt substitution
setopt prompt_subst

# --- Configuration & Assets ---
THEME_DIR="${0:A:h}"

# 1. Random Text
git_texts=("Keep Coding" "Stay Hard" "Focus" "Ship It" "Debug Mode" "Arch User" "Terminal Addict")
if [[ -f "$THEME_DIR/nauty-zsh-random-texts.txt" ]]; then
  git_texts=(${(f)"$(<"$THEME_DIR/nauty-zsh-random-texts.txt")"})
fi

# 2. Doodles
random_doodles=(
  "( ✦ ‿ ✦ )" "✧( ु•⌄• )" "[ ✦_✦ ]" "*( ◕ ◡ ◕ )*" "⟡"
  "✧･ﾟ: *" "<( ✦ )>" "☾˙❀" "【 ✦ 】" "⚡"
)

# --- Helper Functions ---
get_random_doodle() {
  local index=$(( RANDOM % ${#random_doodles[@]} + 1 ))
  echo "${random_doodles[$index]}"
}

get_random_msg() {
  echo "${git_texts[$RANDOM % ${#git_texts[@]} + 1]}"
}

# --- Heavy Logic: Version Detection (Run only on dir change) ---
detect_project_versions() {
  local versions=""
  
  # Go
  [[ -f "go.mod" ]] && versions+=" %B%F{cyan} $(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')%f%b"
  
  # Node
  [[ -f "package.json" ]] && versions+=" %B%F{green} $(node --version 2>/dev/null | sed 's/v//')%f%b"
  
  # Bun
  [[ -f "bun.lockb" || -f "bunfig.toml" ]] && versions+=" %B%F{yellow} $(bun --version 2>/dev/null)%f%b"
  
  # Python
  [[ -f "requirements.txt" || -f "pyproject.toml" ]] && versions+=" %B%F{blue} $(python3 --version 2>/dev/null | awk '{print $2}')%f%b"
  
  # Rust
  [[ -f "Cargo.toml" ]] && versions+=" %B%F{red} $(rustc --version 2>/dev/null | awk '{print $2}')%f%b"

  # Java
  [[ -f "pom.xml" || -f "build.gradle" ]] && versions+=" %B%F{red} $(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')%f%b"

  # Kotlin
  [[ -f "build.gradle.kts" || -f "settings.gradle.kts" ]] && versions+=" %B%F{magenta} $(command -v kotlinc >/dev/null && kotlinc -version 2>&1 | awk '{print $3}')%f%b"

  # PHP
  [[ -f "composer.json" ]] && versions+=" %B%F{blue} $(php --version 2>/dev/null | head -n 1 | cut -d' ' -f2)%f%b"

  # Docker
  [[ -f "Dockerfile" || -f "docker-compose.yml" ]] && versions+=" %B%F{blue} %f%b"

  echo "$versions"
}

# --- Git Prompt (Optimized) ---
git_custom_prompt() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || return

  # Use --porcelain for speed
  local git_status=$(git status --porcelain 2>/dev/null)
  
  local modified=$(echo "$git_status" | grep -c "^.M")
  local total_add=$(echo "$git_status" | grep -c -E "^(A|\?\?)")
  local deleted=$(echo "$git_status" | grep -c "^.D")
  
  local status_text=""
  if [[ -n $git_status ]]; then
    [[ $total_add -gt 0 ]] && status_text+=" %F{green}+${total_add}"
    [[ $modified -gt 0 ]]  && status_text+=" %F{yellow}~${modified}"
    [[ $deleted -gt 0 ]]   && status_text+=" %F{red}-${deleted}"
    status_text="%f${status_text}"
  else
    status_text=" %F{cyan}✦%f"
  fi

  echo " %B%F{magenta} ${ref}${status_text}%f%b"
}

# --- Performance Hook (The Fix) ---
# Initialize variables
typeset -g _last_pwd=""
typeset -g _cached_versions=""

function preexec() {
  timer=${timer:-$SECONDS}
}

function precmd() {
  # 1. Timer Logic
  if [ $timer ]; then
    local timer_show=$(($SECONDS - $timer))
    if [[ $timer_show -ge 2 ]]; then
      export RPROMPT_TIME="%F{yellow}⏱ ${timer_show}s%f "
    else
      export RPROMPT_TIME=""
    fi
    unset timer
  fi

  # 2. Smart Cache for Versions (The lag fix)
  # Only run the heavy detection if the directory changed
  if [[ "$PWD" != "$_last_pwd" ]]; then
    _cached_versions=$(detect_project_versions)
    _last_pwd="$PWD"
  fi
}

get_music_status() {
  if command -v playerctl &> /dev/null; then
    # Quick check first to avoid timeout lag
    if [[ $(playerctl status 2>/dev/null) == "Playing" ]]; then
      local song_full=$(playerctl metadata title 2>/dev/null | head -n 1)
      local song=$song_full
      [[ ${#song_full} -gt 25 ]] && song="${song_full:0:25}..."
      echo " %F{green}🎵 ${song}%f"
    fi
  fi
}

# --- The Prompt Layout ---

# Line 1 uses ${_cached_versions} variable instead of $(function)
PROMPT='
%B%F{blue}╭─%F{cyan}  %n%f%b %F{magenta}$(get_random_doodle)%f %B%F{blue} %~%f%b$(git_custom_prompt)${_cached_versions}
%B%F{blue}╰─%F{magenta} ✦ %* ✦%f '

# Right Prompt
RPROMPT='${RPROMPT_TIME}%b$(get_music_status) %F{242}$(get_random_msg)%f'