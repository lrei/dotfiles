# Setup fzf
# ---------
case "$OSTYPE" in
  darwin*)
    if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
      export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
    fi
    [[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null
    source "/usr/local/opt/fzf/shell/key-bindings.zsh"
  ;;
  linux*)
    [[ $- == *i* ]] && source "/usr/share/doc/fzf/examples/completion.zsh" 2> /dev/null
    source "/usr/share/doc/fzf/examples/key-bindings.zsh"
  ;;
esac
