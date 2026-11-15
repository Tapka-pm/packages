# Tapka package catalog

Recipes live in `packages/<id>/config.json`. Match the directory name to the package ID and use `package-schema.json` as the reference for the format.

- Use version-specific HTTPS URLs from upstream. Verify the checksum for the exact artifact and architecture. Omit `download` while an artifact is pending.
- Keep one current release per maintained release line in `versions`. When a release supersedes another in the same line, replace the old entry and update the affected aliases in the same commit. Git history retains superseded recipes.
- Keep `latest` as the default. Publish aliases such as `lts` or `sts` when they apply to the package. Check that aliases resolve to published releases without cycles and that dependencies support the architectures of the release that uses them.
- Keep install scripts compatible with PowerShell 7. They receive a verified local artifact as `-Installer` and stage files in `-Destination`. When a recipe also sets `install.archive`, Tapka extracts the archive into `-Destination` before running the script. Tapka handles publishing the staged files, shims, and PATH.
- From the repository root, validate each changed recipe with `Test-Json -Json (Get-Content -Raw packages/<id>/config.json) -SchemaFile package-schema.json` in PowerShell 7. If you change the schema, validate all recipes.
