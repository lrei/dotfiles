
##############################################################################
# PATH management (zsh)
# - Define all desired path entries once in PATH_ADD, in priority order.
# - "Earlier entries have higher priority" → they should appear first.
# - Only existing directories are added.
# - Duplicates are avoided (exact segment matches only).
# - Implemented in ~/.zshenv so both interactive and non-interactive shells
#   (e.g., scripts, cron) inherit the same PATH.
##############################################################################

# 1) Edit this list to add/remove search paths.
#    Keep highest-priority paths at the top.
typeset -ga PATH_ADD=(
  "$HOME/.local/bin"   # user-installed tools (pip --user, cargo, etc.)
  "$HOME/bin"          # personal scripts
  "$HOME/apps"         # personal apps
  "$HOME/.opencode/bin" # opencode
  "/usr/local/bin"     # macOS (Intel) Homebrew
  "/usr/local/sbin"     # macOS (Intel) Homebrew
)

# 2) Build PATH so that earlier entries in PATH_ADD appear leftmost in PATH.
#    We iterate the array in reverse and *prepend* each item.
#    Prepending in reverse preserves the original order at the front.
for (( i=${#PATH_ADD[@]}-1; i>=0; i-- )); do
  p=${PATH_ADD[i]}

  # Skip if the directory doesn't exist (keeps PATH clean across machines)
  [[ -d "$p" ]] || continue

  # Avoid duplicates with a whole-segment match by wrapping PATH in colons.
  # This prevents false matches (e.g., /usr/local/bin vs /usr/local/binance).
  case ":$PATH:" in
    *:"$p":*) ;;            # already present → do nothing
    *) PATH="$p:$PATH" ;;   # not present → prepend to give it higher priority
  esac
done

# 3) Export the final PATH for all processes spawned from this shell.
export PATH

##############################################################################
# Notes:
# - Priority: the shell searches PATH from left to right. Leftmost wins.
#   Because we *prepend* in reverse order, the first item in PATH_ADD ends up
#   closest to the left → highest priority.
# - Portability: the loop uses zsh array features; keep this in zshenv.
#   If you need POSIX sh compatibility, ask and I’ll provide a variant.
# - macOS: if you use Homebrew on Apple Silicon, ensure /opt/homebrew/bin exists.
# - Troubleshooting: run `print -l ${(s.:.)PATH}` to inspect PATH segments.
##############################################################################

# -------------------------------------------------------------------------  #


# #############################################
#  -------------- HUGGINGFACE --------------- # 
# #############################################
# HF_HOME alone is sufficient — HF_HUB_CACHE / TRANSFORMERS_CACHE /
# HF_DATASETS_CACHE all derive from it automatically (huggingface_hub >= 0.14).
# Per-host override (e.g. /data/hf on a machine with a big disk):
#   create ~/.config/hf.env containing:  HF_HOME=/data/hf
# (~/.config/hf.env is not tracked by the dotfiles repo.)
: "${HF_HOME:=$HOME/dev/hf}"
[[ -r ~/.config/hf.env ]] && source ~/.config/hf.env
export HF_HOME
[[ -d "$HF_HOME" ]] || mkdir -p "$HF_HOME" 2>/dev/null

# -------------------------------------------------------------------------  #
