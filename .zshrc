#!/bin/zsh

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PATH="$PATH:$HOME/.local/bin"

# Clean Python caches from the current directory tree
function clean_python_caches() {
    echo ">>> Cleaning Python caches..."
    find . -type d -name '__pycache__' -exec rm -r {} + 2>/dev/null || true
    find . -type d -name '.mypy_cache' -exec rm -r {} + 2>/dev/null || true
    find . -type d -name '.pytest_cache' -exec rm -r {} + 2>/dev/null || true
    find . -type d -name '.ruff_cache' -exec rm -r {} + 2>/dev/null || true
    find . -type d -name '*.egg-info' -exec rm -r {} + 2>/dev/null || true
    find . -type d -name 'htmlcov' -exec rm -r {} + 2>/dev/null || true
    find . -type f -name '.coverage*' -exec rm -r {} + 2>/dev/null || true
    echo ">>> Python caches cleaned."
}

# Remove virtual environment and clean Python caches
function remove_venv() {
    # Deactivate current virtual environment if active
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo ">>> Deactivating current virtual environment..."
        deactivate 2>/dev/null || true
    fi

    # Clean Python caches
    clean_python_caches

    # Remove build directory if it exists
    if [ -d "build" ]; then
        echo ">>> Removing existing build directory..."
        rm -rf build
    fi

    # Remove existing venv if it exists
    if [ -d ".venv" ]; then
        echo ">>> Removing existing .venv directory..."
        rm -rf .venv
        echo ">>> Virtual environment removed."
    else
        echo ">>> No .venv directory found."
    fi
}

# Check if gcloud is logged in (both auth and application-default)
function is_gcloud_logged_in() {
    local auth_logged=false
    local app_default_logged=false

    # Check regular auth login
    if echo "" | gcloud projects list &> /dev/null; then
        auth_logged=true
    fi

    # Check application-default login
    if echo "" | gcloud auth application-default print-access-token &> /dev/null; then
        app_default_logged=true
    fi

    if [[ "$auth_logged" == true ]] && [[ "$app_default_logged" == true ]]; then
        return 0
    else
        return 1
    fi
}

# Ensure gcloud is logged in and set up UV_EXTRA_INDEX_URL
function ensure_gcloud_login() {
    echo ">>> Checking gcloud authentication status..."

    # Check if gcloud command exists
    if ! command -v gcloud &> /dev/null; then
        echo ">>> Error: gcloud is not installed or not in PATH."
        return 1
    fi

    # Check regular auth login
    if ! (echo "" | gcloud projects list &> /dev/null); then
        echo ">>> Not logged into gcloud. Running 'gcloud auth login'..."
        echo ">>> This will open a browser window for authentication."

        gcloud auth login

        if [ $? -ne 0 ]; then
            echo ">>> Error: Failed to login to gcloud."
            return 1
        fi
    else
        echo ">>> Already logged into gcloud."
    fi

    # Check application-default login
    if ! (echo "" | gcloud auth application-default print-access-token &> /dev/null); then
        echo ">>> Application default credentials not set. Running 'gcloud auth application-default login'..."
        echo ">>> This will open a browser window for authentication."

        gcloud auth application-default login

        if [ $? -ne 0 ]; then
            echo ">>> Error: Failed to set application default credentials."
            return 1
        fi
    else
        echo ">>> Application default credentials already set."
    fi

    echo ">>> gcloud authentication complete."
    return 0
}

# Create a new virtual environment using uv
function create_venv() {
    # Check if uv is installed
    if ! command -v uv &> /dev/null; then
        echo ">>> Error: uv is not installed or not in PATH."
        return 1
    fi

    # Verify that we can create a venv using uv in this directory
    if [[ ! -f "pyproject.toml" && ! -f "requirements.txt" && ! -f "requirements.in" ]]; then
        echo ">>> Error: No pyproject.toml or requirements file found in current directory."
        echo ">>> Cannot create a virtual environment without project dependencies."
        return 1
    fi

    # Create new venv
    echo ">>> Creating new virtual environment with uv..."
    uv venv

    if [ $? -ne 0 ]; then
        echo ">>> Error: Failed to create virtual environment."
        return 1
    fi

    # Activate the environment
    echo ">>> Activating virtual environment..."
    source .venv/bin/activate

    # Install dependencies
    echo ">>> Installing dev dependencies..."
    uv sync --only-dev

    if [ $? -ne 0 ]; then
        echo ">>> Error: Failed to install dev dependencies."
        return 1
    fi

    echo ">>> Installing regular dependencies..."
    uv sync

    if [ $? -ne 0 ]; then
        echo ">>> Error: Failed to install regular dependencies."
        return 1
    fi

    # Install current package in development mode if pyproject.toml exists
    if [ -f "pyproject.toml" ]; then
        echo ">>> Installing current package..."
        uv pip install .

        if [ $? -ne 0 ]; then
            echo ">>> Error: Failed to install current package."
            return 1
        fi
    fi

    echo ">>> Virtual environment created and dependencies installed."
}

# Main function to recreate the uv environment with gcloud authentication
function recreate_uv_env() {
    # Ensure gcloud is logged in and set up UV_EXTRA_INDEX_URL
    ensure_gcloud_login

    if [ $? -ne 0 ]; then
        echo ">>> Error: Failed to set up gcloud authentication."
        return 1
    fi

    # Remove existing virtual environment
    remove_venv

    # Set UV_KEYRING_PROVIDER to subprocess to avoid keyring issues
    export UV_KEYRING_PROVIDER=subprocess

    # Set UV_EXTRA_INDEX_URL with the access token
    refresh_uv_token_no_login_check

    # Create new virtual environment and install dependencies
    create_venv

    if [ $? -ne 0 ]; then
        echo ">>> Error: Failed to create virtual environment."
        return 1
    fi

    echo ">>> Environment recreation complete!"
}

# Convenience function to just log into gcloud without recreating venv
function gcloud_login() {
    ensure_gcloud_login
}

# Convenience function to just log out of gcloud without recreating venv
function gcloud_logout() {
    echo ">>> Logging out of gcloud..."
    gcloud auth revoke --quiet

    echo ">>> Logging out of gcloud application-default..."
    gcloud auth application-default revoke --quiet
}

# Function to refresh the UV_EXTRA_INDEX_URL token (useful when token expires)
function refresh_uv_token() {
    if is_gcloud_logged_in; then
        refresh_uv_token_no_login_check
    else
        echo ">>> Not logged into gcloud. Please run 'gcloud_login' first."
        return 1
    fi
}

function refresh_uv_token_no_login_check() {
    echo ">>> Refreshing UV_EXTRA_INDEX_URL token..."
    export UV_EXTRA_INDEX_URL="https://oauth2accesstoken:$(gcloud auth print-access-token)@europe-python.pkg.dev/giza-platform-common/giza-packages/simple"
    echo ">>> Token refreshed."
}

# Switch .env file to a different environment
# Usage: envswitch <environment>  (e.g. envswitch giza-dev)
# Tab-completion supported via ~/.zfunc/_envswitch
function envswitch() {
    if [[ -z "$1" ]]; then
        echo "Usage: envswitch <environment>"
        echo "Available environments:"

        for f in .env.*; do
            [[ -f "$f" ]] && echo "  ${f#.env.}"
        done

        return 1
    fi

    local envfile=".env.$1"
    if [[ ! -f "$envfile" ]]; then
        echo "Error: $envfile not found"
        echo "Available environments:"

        for f in .env.*; do
            [[ -f "$f" ]] && echo "  ${f#.env.}"
        done

        return 1
    fi

    ln -sf "$envfile" .env
    echo "Switched to $1 (.env -> $envfile)"
}

fpath+=~/.zfunc; autoload -Uz compinit; compinit
