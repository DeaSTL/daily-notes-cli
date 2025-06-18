#!/usr/bin/env bash

set -e
# === CONFIG ===
REPO_URL="https://github.com/DeaSTL/daily-notes-cli"
NOTES_CLI_DIR="daily-notes-cli"
DEFAULT_NOTES_DIR="$HOME/.notes"
INSTALL_PATH="$HOME/.local/bin"
NOTES_COMMAND="notes"
GIT_REPO=


prompt_notes_dir() {
  read -p "Enter the directory to store notes [$DEFAULT_NOTES_DIR]: " user_notes_input
  NOTES_DIR="${user_notes_input:-$DEFAULT_NOTES_DIR}"
}

prompt_git() {
  read -p "Would you like to set up a git repository? [yes|no] " user_git_choice
  if [ "$user_git_choice" != "yes" ] && [ "$user_git_choice" != "no" ]; then
    prompt_git
  fi

  if [  "$user_git_choice" = "yes" ]; then
    if [ ! -d .git ]; then
      echo "🔧 Initializing Git repository"
      git init

      read -p "Please provide a git repository: " user_git_repo
      if [ "$user_git_repo" != "" ]; then
        git remote add origin "$user_git_repo"
      fi
    else
      echo "Git already exists"
    fi

  fi
}

# === MAIN ===
echo "Installing notes command"
mkdir -p "$INSTALL_PATH"
(git clone "$REPO_URL" /tmp/notes && cd /tmp/notes/ && cp ./notes  "$INSTALL_PATH/$NOTES_COMMAND" && rm -rf /tmp/notes/)
chmod +x "$INSTALL_PATH/$NOTES_COMMAND"

prompt_git

prompt_notes_dir

echo "Creating notes directory"
mkdir -p "$NOTES_DIR"
cd "$NOTES_DIR"

# == Command Setup ==
if [[ ":$PATH:" != *":$INSTALL_PATH:"* ]]; then
  echo "Adding to path"
  export PATH="$INSTALL_PATH:$PATH"

  SHELL_CONFIG=""
  if [[ $SHELL == */bash ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
  elif [[ $SHELL == */zsh ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
  fi

  if [[ -n "$SHELL_CONFIG" ]]; then
    echo "export PATH=\"$INSTALL_PATH:\$PATH\"" >> "$SHELL_CONFIG"
    echo "Completed"
  else
    echo "Could not detect shell config, plese add '$INSTALL_PATH' to your PATH"
  fi
else
  echo "$INSTALL_PATH already exists"
fi

command -v notes || echo "'notes' command not found, you may need to restart the shell"

echo "Setup complete"
