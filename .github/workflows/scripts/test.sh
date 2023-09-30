curl -v -L \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer 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" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/janiswehen/AI-Functions/issues/50/labels \
  -d '{"labels":["bug","enhancement"]}'