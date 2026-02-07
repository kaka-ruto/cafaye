# 🚀 Releasing Cafaye OS

This document describes how to cut a new release of Cafaye OS.

## Prerequisites

- All tests pass: `nix flake check`
- All changes committed (no uncommitted work)
- You are on the `master` branch

## Release Process

### 1. Update Version File

```bash
# Update the version file
echo "0.1.0" > version
```

### 2. Update Changelog

Edit `CHANGELOG.md`:

1. Move items from `[Unreleased]` to a new version section
2. Add the release date
3. Ensure all notable changes are documented

```markdown
## [0.1.0] - 2024-XX-XX

### Added
- Feature A
- Feature B

### Fixed
- Bug X
```

### 3. Commit the Release

```bash
git add version CHANGELOG.md
git commit -m "Release v0.1.0"
```

### 4. Tag the Release

```bash
git tag -a v0.1.0 -m "Release v0.1.0"
```

### 5. Push to Remote

```bash
git push origin master
git push origin v0.1.0
```

### 6. Create GitHub Release

1. Go to GitHub → Releases → "Draft a new release"
2. Select the tag `v0.1.0`
3. Title: `v0.1.0`
4. Description: Copy from CHANGELOG.md
5. Publish release

---

## Version Numbering

We use [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
```

| Component | When to Increment |
| :--- | :--- |
| **MAJOR** | Breaking changes to user configuration or CLI |
| **MINOR** | New features, new modules, new commands |
| **PATCH** | Bug fixes, documentation, minor improvements |

### Pre-1.0 Rules

During `0.x.x` development:
- Each MINOR version corresponds to a development phase
- PATCH versions are for fixes within a phase
- Breaking changes are expected and don't require MAJOR bump

### Examples

| Change | Version Bump |
| :--- | :--- |
| Add new language module | `0.4.0` → `0.4.1` (if in phase 4) |
| Fix bug in CLI | `0.3.0` → `0.3.1` |
| Complete Phase 5 | `0.4.x` → `0.5.0` |
| Breaking config change post-1.0 | `1.2.3` → `2.0.0` |

---

## Release Channels

Cafaye supports multiple release channels (implemented in Phase 9):

| Channel | Branch | Stability | Audience |
| :--- | :--- | :--- | :--- |
| **stable** | `master` (tagged) | Production-ready | All users |
| **rc** | `rc` | Release candidate | Early adopters |
| **edge** | `master` (HEAD) | Latest features | Testers |
| **dev** | `dev` | Experimental | Developers only |

### Channel Commands

```bash
# Switch channels (available after Phase 9)
caf-channel-set stable
caf-channel-set edge
caf-channel-set dev
```

---

## Pre-Release Checklist

Before every release, verify:

- [ ] `nix flake check` passes
- [ ] All phase checklist items in DEVELOPMENT.md are complete
- [ ] Documentation is up to date
- [ ] CHANGELOG.md is updated
- [ ] Version file is updated
- [ ] No TODO comments referencing this release
- [ ] Manual smoke test on a fresh VPS (for major releases)

---

## Hotfix Process

For critical fixes to a released version:

1. Create branch from the release tag:
   ```bash
   git checkout -b hotfix/v0.4.1 v0.4.0
   ```

2. Apply the fix and test

3. Update version and changelog:
   ```bash
   echo "0.4.1" > version
   # Edit CHANGELOG.md
   ```

4. Commit, tag, and push:
   ```bash
   git add version CHANGELOG.md <fixed-files>
   git commit -m "Fix critical bug in XYZ"
   git tag -a v0.4.1 -m "Hotfix v0.4.1"
   git push origin hotfix/v0.4.1
   git push origin v0.4.1
   ```

5. Merge back to master:
   ```bash
   git checkout master
   git merge hotfix/v0.4.1
   git push origin master
   ```

---

## Automation (Future)

In Phase 1, we'll set up GitHub Actions to:

1. Run `nix flake check` on every push
2. Build and cache binaries on Cachix
3. Auto-create GitHub releases when tags are pushed
4. Generate release notes from CHANGELOG.md
