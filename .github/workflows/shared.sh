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

PROJ_ID=""
proj_id() {
  if [[ -z "$PROJ_ID" ]]; then
    login
    PROJ_ID="$(api "repos/:owner/:repo/projects" | jq -r '.[0]')"
  fi
  echo "$PROJ_ID"
}

# col="$(api "projects/$proj/columns" | jq -r '.[] | @text "\(.name):\(.id)"' | \
#          grep -Ei "^To ?do:")"
# col="${col##*:}"
