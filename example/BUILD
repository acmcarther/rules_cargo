load("@io_bazel_rules_cargo//cargo:cargo.bzl", "cargo_binary_tar")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")


filegroup(
    name = "hello_world_source",
    srcs = ["hello_world.tar.gz"]
)

filegroup(
    name = "cargo_raze_source",
    srcs = ["cargo-raze.tar.gz"]
)

cargo_binary_tar(
    name = "hello_world",
    crate_tar = ":hello_world_source"
)

cargo_binary_tar(
    name = "cargo-raze",
    crate_tar = ":cargo_raze_source"
)
