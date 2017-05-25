workspace(name = "io_bazel_rules_cargo")

load("//cargo:repositories.bzl", "cargo_repositories")

cargo_repositories()

git_repository(
    name = "io_bazel_rules_rust",
    remote = "https://github.com/bazelbuild/rules_rust.git",
    commit = "442276a"
)
load("@io_bazel_rules_rust//rust:repositories.bzl", "rust_repositories")

rust_repositories()
