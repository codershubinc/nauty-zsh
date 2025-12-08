# Enable prompt substitution
setopt prompt_subst

# --- Configuration & Assets ---
# Get the directory where this theme file is located
THEME_DIR="${0:A:h}"

# 1. Random Text Loader (With Fallback)
git_texts=("Keep Coding" "Stay Hard" "Focus" "Ship It" "Debug Mode" "Arch User" "Sudo Make Me a Sandwich")
if [[ -f "$THEME_DIR/nauty-zsh-random-texts.txt" ]]; then
  git_texts=(${(f)"$(<"$THEME_DIR/nauty-zsh-random-texts.txt")"})
fi

# 2. Doodles Array
random_doodles=(
  "(ﾉ◕ヮ◕)ﾉ" "( ͡° ͜ʖ ͡°)" "(づ｡◕‿‿◕｡)づ" "ヽ(´▽\`)/" "(つ°ヮ°)つ"
  "ʕ•ᴥ•ʔ" "(⌐■_■)" "¯\\_(ツ)_/¯" "(╯°□°）╯︵ ┻━┻" "┬─┬ノ( º _ ºノ)"
  "☜(ﾟヮﾟ☜)" "ᕕ( ᐛ )ᕗ" "ಠ_ಠ" "(ง'̀-'́)ง" "└(￣-￣└)" "⚡" "💀" "👽"
)

# --- Helper Functions ---

get_random_doodle() {
  local index=$(( RANDOM % ${#random_doodles[@]} + 1 ))
  echo "${random_doodles[$index]}"
}

get_random_msg() {
  echo "${git_texts[$RANDOM % ${#git_texts[@]} + 1]}"
}

# --- Version Detection (Fixed for Width) ---
detect_project_versions() {
  local versions=""
  
  # Go
  if [[ -f "go.mod" ]]; then
    local v=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    versions+=" %B%F{cyan} ${v}%f%b"
  fi
  
  # Node / JS
  if [[ -f "package.json" ]]; then
    local v=$(node --version 2>/dev/null | sed 's/v//')
    versions+=" %B%F{green} ${v}%f%b"
  fi
  
  # Bun
  if [[ -f "bun.lockb" || -f "bunfig.toml" ]]; then
    local v=$(bun --version 2>/dev/null)
    versions+=" %B%F{yellow} ${v}%f%b"
  fi
  
  # Python
  if [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" ]]; then
    local v=$(python3 --version 2>/dev/null | awk '{print $2}')
    versions+=" %B%F{blue} ${v}%f%b"
  fi
  
  # Rust
  if [[ -f "Cargo.toml" ]]; then
    local v=$(rustc --version 2>/dev/null | awk '{print $2}')
    versions+=" %B%F{red} ${v}%f%b"
  fi

  # Java
  if [[ -f "pom.xml" || -f "build.gradle" ]]; then
    local v=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    versions+=" %B%F{magenta} ${v}%f%b"
  fi
  
  echo "$versions"
}

# --- Git Prompt (Fixed for Width) ---
git_custom_prompt() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || return

  local git_status=$(git status --porcelain 2>/dev/null)
  local added=$(echo "$git_status" | grep -c "^A")
  local modified=$(echo "$git_status" | grep -c "^.M")
  local deleted=$(echo "$git_status" | grep -c "^.D")
  local untracked=$(echo "$git_status" | grep -c "^??")
  
  local status_text=""
  if [[ -n $git_status ]]; then
    local total_add=$((added + untracked))
    [[ $total_add -gt 0 ]] && status_text+=" %F{green}+${total_add}"
    [[ $modified -gt 0 ]]  && status_text+=" %F{yellow}~${modified}"
    [[ $deleted -gt 0 ]]   && status_text+=" %F{red}-${deleted}"
    status_text="%f${status_text}"
  else
    status_text=" %F{green}✔%f"
  fi

  echo " %B%F{magenta} ${ref}${status_text}%f%b"
}

# --- The Prompt Layout ---

# We use %F{color} and %B (bold) which Zsh calculates correctly
# Line 1: [User] [Doodle] [Path] [Git] [Versions]
# Line 2: [Time] ❯ 

PROMPT='
%B%F{cyan}╭─ %n%f%b $(get_random_doodle)  %B%F{blue} %~%f%b$(git_custom_prompt)$(detect_project_versions)
%B%F{cyan}╰─%F{yellow}  %* ❯%f%b '

# Right Prompt
RPROMPT='%F{240}$(get_random_msg)%f'