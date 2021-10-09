LOGGED_IN=0
login() {
  if ((LOGGED_IN)); then return; fi
  echo "Logging into GH"
  gh auth login --with-token <<<"$GH_TOKEN" | exit 1
  LOGGED_IN=1
}

HDRS=()
# HDRS=(-H "Accept:application/vnd.github.inertia-preview+json")
api() { gh api "${HDRS[@]}" "$@"; }

PROJs=""
get_PROJs() {
  if [[ -n "$PROJs" ]]; then return; fi
  login
  PROJS="$(api "repos/:owner/:repo/projects")"
}

# col="$(api "projects/$proj/columns" | jq -r '.[] | @text "\(.name):\(.id)"' | \
#          grep -Ei "^To ?do:")"
# col="${col##*:}"
