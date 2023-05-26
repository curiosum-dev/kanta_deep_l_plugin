import Config

config :versioce,
  post_hooks: [Versioce.PostHooks.Changelog]

config :versioce, :changelog,
  datagrabber: Versioce.Changelog.DataGrabber.Git,
  formatter: Versioce.Changelog.Formatter.Keepachangelog,
  anchors: %{
    added: ["add:", "build:"],
    changed: ["chore:", "refactor:", "feat:", "docs:", "ci:"],
    deprecated: [],
    removed: ["revert:"],
    fixed: ["fix:", "perf:"],
    security: []
  }
