# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
hub_path=$(which hub)
if (( $+commands[hub] ))
then
  alias git=$hub_path
fi

# The rest of my fun git aliases
alias ga="git add ."
alias gc="git commit -m"

alias gs="git status --short"
alias gsl="git status"
alias gso="git status -sb"
alias gl="git smart-log"
alias gd='git diff'

alias gco="git checkout"
alias gcob="git checkout -b"
alias gb="git branch"
alias gbd="git branch -D"

alias gf="git fetch"
alias gpu="git pull"
alias gph="git push"
alias gm="git merge"

alias gr="git remote -v"
