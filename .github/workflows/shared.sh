LOGGED_IN=0
login() {
  if ((LOGGED_IN)); then return; fi
  echo "Logging into GH"
  gh auth login --with-token <<<"$GH_TOKEN"
}

HDRS=()
# HDRS=(-H "Accept:application/vnd.github.inertia-preview+json")
api() { gh api "${HDRS[@]}" "$@"; }

# proj="$(api "repos/:owner/:repo/projects" | jq -r '.[0].id')"
# col="$(api "projects/$proj/columns" | jq -r '.[] | @text "\(.name):\(.id)"' | \
#          grep -Ei "^To ?do:")"
# col="${col##*:}"
