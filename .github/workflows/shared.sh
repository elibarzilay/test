gh auth login --with-token <<<"$GH_TOKEN"

H=(-H "Accept:application/vnd.github.inertia-preview+json")
api() { gh api "${H[@]}" "$@"; }

proj="$(api "repos/:owner/:repo/projects" | jq -r '.[0].id')"
col="$(api "projects/$proj/columns" | jq -r '.[] | @text "\(.name):\(.id)"' | \
         grep -Ei "^To ?do:")"
col="${col##*:}"
