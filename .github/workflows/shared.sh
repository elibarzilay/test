# =============================================================================

BATCH_SIZE=4
BOARD="Test"
COL1="To do"
COL2="In progress"
COL3="Done"

# =============================================================================

noop() { echo "Nothing to do ($*)"; exit 0; }

LOGGED_IN=0
if [[ -n "$GH_TOKEN" ]]; then LOGGED_IN=1; fi
login() {
  if ((LOGGED_IN)); then return; fi
  echo "Logging into GH"
  gh auth login --with-token <<<"$GH_TOKEN" | exit 1
  LOGGED_IN=1
}

HDRS=()
# HDRS=(-H "Accept:application/vnd.github.inertia-preview+json")
api() { gh api "${HDRS[@]}" "$@"; }

jget() { json="$1"; shift; jq -r "$* // empty" <<<"$json"; }
ctx() { jget "$GH_CTX" "$@"; }

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

LABELs=""
get_LABELs() {
  if [[ -n "$LABELs" ]]; then return; fi
  login
  LABELs="$(gh api "/repos/{owner}/{repo}/labels" | \
            jq -j '.[] | @text ":\(.name // empty)"'):"
}
mk_label() {
  get_LABELs
  if [[ "$LABELs" = *:"$1":* ]]; then return; fi
  echo "Creating label: $1"
  LABELs=":$1$LABELs"
  gh api "/repos/{owner}/{repo}/labels" -f name="$1"
}

MILESTONEs=""
get_MILESTONEs() {
  if [[ -n "$MILESTONEs" ]]; then return; fi
  login
  MILESTONEs="$(gh api "/repos/{owner}/{repo}/milestones" | \
                jq -j '.[] | @text ":\(.title // empty)"'):"
}
mk_milestone() {
  get_MILESTONEs
  if [[ "$MILESTONEs" = *:"$1":* ]]; then return; fi
  echo "Creating milestone: $1"
  MILESTONEs=":$1$MILESTONEs"
  gh api "/repos/{owner}/{repo}/milestones" -f title="$1" \
     -f due_on="$(date -d "next week" +"%FT%TZ")"
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
