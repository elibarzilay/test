###############################################################################

BOARD="Test"

###############################################################################

LOGGED_IN=0
login() {
  if ((LOGGED_IN)); then return; fi
  echo "Logging into GH"
  gh auth login | exit 1
  LOGGED_IN=1
}

HDRS=()
# HDRS=(-H "Accept:application/vnd.github.inertia-preview+json")
api() { gh api "${HDRS[@]}" "$@"; }

ctx() {
  jq -r "$*" <<<"$GH_CTX"
}

LF=$'\n'
# convert an id to a name or the other way
id_name() { # table id-or-name
  local rx="$LF([^$LF]*):$2:([^$LF]*)$LF"
  if [[ "$1" =~ $rx ]]; then
    echo "${BASH_REMATCH[1]#:}${BASH_REMATCH[2]%:}"
  else
    echo "error: could not find $2 in {$1}" 1>&2; exit 1
  fi
}

PROJs=""
get_PROJs() {
  if [[ -n "$PROJs" ]]; then return; fi
  login
  PROJs="$(api "repos/:owner/:repo/projects" | \
           jq -r '.[] | @text ":\(.name):\(.id):"')"
  PROJs="$LF$PROJs$LF"
}
proj() { get_PROJs; id_name "$PROJs" "$1"; }

COLs=""
get_COLs() {
  get_PROJs
  COLs="$(api "projects/$(proj "$BOARD")/columns" | \
          jq -r '.[] | @text ":\(.name):\(.id):"')"
  COLs="$LF$COLs$LF"
}
col() { get_COLs; id_name "$COLs" "$1"; }
