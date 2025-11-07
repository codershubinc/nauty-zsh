# Load the color helper
autoload -U colors && colors

# --- Random Text Function ---
# Get the directory where this theme file is located
THEME_DIR="${0:A:h}"

# Load random texts from external file
local git_texts=()
if [[ -f "$THEME_DIR/nauty-zsh-random-texts.txt" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && git_texts+=("$line")
  done < "$THEME_DIR/nauty-zsh-random-texts.txt"
fi

# Function to get random text
get_random_git_text() {
  echo "${git_texts[$RANDOM % ${#git_texts[@]} + 1]}"
}

# --- Optional Git Customization ---
# You can change the symbols OMZ uses for Git
ZSH_THEME_GIT_PROMPT_PREFIX="\$(get_random_git_text) this Branch  => ${fg[magenta]}("   # Text before the branch name
ZSH_THEME_GIT_PROMPT_SUFFIX=")${reset_color}" # Text after the branch name
ZSH_THEME_GIT_PROMPT_DIRTY=" ✗"                # Symbol for "dirty" (unsaved changes)
ZSH_THEME_GIT_PROMPT_CLEAN=" ✔"                # Symbol for "clean" (all saved)
# ----------------------------------

# ---  Dir Customization ---
# You can change the symbols OMZ uses for the current directory
ZSH_THEME_DIR_PREFIX="\$(get_random_git_text) ${fg[blue]}["          # Text before the current directory
ZSH_THEME_DIR_SUFFIX="${reset_color}] "       # Text after the current directory
ZSH_THEME_DIR_MAX_LENGTH=40                   # Maximum length of the current directory
# ----------------------------------


# --- The Prompt ---
# This creates a two-line prompt.
# Line 1: User and Path
# Line 2: The command input
PROMPT='
${fg[cyan]}%n${reset_color} \$(get_random_git_text) ${fg[blue]}[%~${reset_color}] $(git_prompt_info)
${fg[green]}❯${reset_color} '