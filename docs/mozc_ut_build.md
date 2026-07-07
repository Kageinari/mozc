# mozc-ut CI Build

## Why dictionary00.txt is not pushed

After merging mozc-ut entries, `dictionary00.txt` grows to about **214MB**, which
exceeds GitHub's **100MB per-file limit**. The merged dictionary is produced
only in GitHub Actions and must not be committed.

## CI flow

1. `scripts/ci/merge_mozc_ut.sh` clones [merge-ut-dictionaries](https://github.com/utuhiro78/merge-ut-dictionaries) at a pinned commit
2. Builds `mozcdic-ut.txt` and validates TSV format
3. Appends to `src/data/dictionary_oss/dictionary00.txt` in the workspace
4. Bazel builds the Windows installer (MSI)

Pin version in `scripts/ci/mozc_ut.env` (`MERGE_UT_REF`).

## Local development

- Keep the OSS `dictionary00.txt` in git (~7MB)
- For local UT testing, merge manually but do not `git add` the enlarged file
- Use `git update-index --skip-worktree src/data/dictionary_oss/dictionary00.txt` if needed

## Android APK signing

APK signing belongs in [MozcForAndroid](https://github.com/kageinari/MozcForAndroid), not in mozc `android.yaml` (mozc CI builds `native_libs.zip` only).