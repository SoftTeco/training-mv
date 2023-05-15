module.exports = {
  verifyRelease: [
    {
      path: "@semantic-release/exec",
      cmd: "echo RELEASE_VERSION=${nextRelease.version} >> $GITHUB_ENV",
    },
  ],
  branches: [
    "+([0-9])?(.{+([0-9]),x}).x",
    "main",
    "next",
    "next-major",
    {name: "beta", prerelease: true},
    {name: "alpha", prerelease: true},
    {name: "feature/FA-*", channel: "feature"},
  ],
  plugins: [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    [
      "@semantic-release/github",
      {
        assets: ["CHANGELOG.md"],
      },
    ],
    [
      "@semantic-release/changelog",
      {
        changelogFile: "CHANGELOG.md",
        changelogTitle: "# Semantic Versioning Changelog",
      },
    ],
  ],
};
