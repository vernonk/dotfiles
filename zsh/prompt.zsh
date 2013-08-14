# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    # Uncomment below to show username before dir list
    # prompt_segment black default "%(!.%{%F{yellow}%}.)$user@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '\u271a'
    # zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:git:*' unstagedstr '\u2731'
    # zstyle ':vcs_info:git:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats '%u%c'

    vcs_info
    #
    #
    # zstyle ':vcs_info:*' stagedstr 'VV'
    # zstyle ':vcs_info:*' unstagedstr 'KK'
    # zstyle ':vcs_info:*' check-for-changes true
    # # zstyle ':vcs_info:*' actionformats '%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
    # # zstyle ':vcs_info:*' formats \
    #   # '%F{5}[%F{2}%b%F{5}] %F{2} %F{2}%c%F{3}%u%f'
    # zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
    # zstyle ':vcs_info:*' enable git
    # +vi-git-untracked() {
    #   if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
    #     git status --porcelain | grep '??' &> /dev/null ; then
    #     hook_com[unstaged]+='\u2731'
    #   fi
    # }

    # vcs_info


    # if [[ $dirty == "DIRTY" ]]; then
    #   echo "DIRTY SON"
    # else
    #   echo "NOT DIRTY SON"
    # fi

    MESSAGE=$vcs_info_msg_0_

    # echo $dirty
    # echo $MESSAGE


    if [[ "${#MESSAGE}" -eq 1 ]]; then
      MESSAGE=" \u2714"
    fi

    echo -n "${ref/refs\/heads\// } $MESSAGE"
    # echo -n "${ref/refs\/heads\// } ${vcs_info_msg_0_}"
  fi
}
#
# prompt_git() {
#     local git_status="`git status -unormal 2>&1`"
#     if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
#         if [[ "$git_status" =~ nothing\ to\ commit ]]; then
#             local ansi=42
#         elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
#             local ansi=43
#         else
#             local ansi=45
#         fi
#         if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
#             branch=${BASH_REMATCH[1]}
#             test "$branch" != master || branch=' '
#         else
#             # Detached HEAD.  (branch=HEAD is a faster alternative.)
#             branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
#                 echo HEAD`)"
#         fi
#         # echo -n '\[\e[0;37;'"$ansi"';1m\]'"$branch"'\[\e[0m\] '
#     fi
# }

prompt_hg() {
  local rev status
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green black
      fi
      echo -n $(hg prompt " {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -Eq "^\?"`; then
        prompt_segment red black
        st='±'
      elif `hg st | grep -Eq "^(M|A)"`; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green black
      fi
      echo -n " $rev@$branch" $st
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue white '\u2605  %~'
}
# Uncomment below to show just the current dir
#prompt_dir() {
  #prompt_segment blue black $(basename "$PWD")
#}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path ]]; then
    prompt_segment blue black "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_hg
  prompt_end
}

export PROMPT='%{%f%b%k%}$(build_prompt) '
