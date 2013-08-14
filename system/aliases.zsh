# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
fi

# alias ll="ls -alGh"
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias cl="clear"

#Allow local file access in Chrome
alias chromelocal="open /Applications/Google\ Chrome.app --args --allow-file-access-from-files"

# ST3
alias subl3="open -a Sublime\ Text"
