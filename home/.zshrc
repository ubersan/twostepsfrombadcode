export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  localalias
)

source $ZSH/oh-my-zsh.sh

export ZSH_THEME_K8S_PROMPT_PREFIX="%{$fg_bold[blue]%}k8s:(%{$fg[red]%}"
export ZSH_THEME_K8S_PROMPT_SUFFIX="%{$fg[blue]%})%{$reset_color%}"

export PROMPT='${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

: ${EDITOR=/bin/nano}
export EDITOR