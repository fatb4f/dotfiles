# Trimmed from Bash-it's general aliases and adapted for Zsh.

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto'
  alias la='eza -TaL1 --group-directories-first --icons=auto'
  alias laa='eza -TaL2 --group-directories-first --icons=auto'
  alias l='eza -A --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah'
  alias la='ls -a'
  alias l='ls -A'
  if command -v tree >/dev/null 2>&1; then
    alias lt='tree -L 2'
  else
    alias lt='find . -print | sed -e '\''s;[^/]*/;|____;g;s;____|; |;g'\'''
  fi
fi

alias c='clear'
alias cls='clear'
alias edit='${EDITOR:-${ALTERNATE_EDITOR:-nvim}}'
alias pager='${PAGER:-less}'
alias q='exit'
alias h='history'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
alias -- -='cd -'
alias dow='cd "$HOME/Downloads"'
alias md='mkdir -p'
alias rd='rmdir'
alias rmrf='rm -rf'

if command -v extract >/dev/null 2>&1; then
  alias xt='extract'
fi

alias svim='sudo "${VISUAL:-${EDITOR:-vim}}"'
alias snano='sudo "${ALTERNATE_EDITOR:-nano}"'

if command -v grep >/dev/null 2>&1; then
  alias grep='grep --color=auto'
fi

if command -v sem >/dev/null 2>&1; then
  alias semd='sem diff'
  alias semi='sem impact'
  alias semb='sem blame'
  alias seml='sem log'
  alias seme='sem entities'
fi
