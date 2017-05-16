package(default_visibility = ["//visibility:public"])

exports_files(["cargo.bzl"])

config_setting(
    name = "darwin",
    values = {"host_cpu": "darwin"},
)

config_setting(
    name = "k8",
    values = {"host_cpu": "k8"},
)

filegroup(
    name = "cargo",
    srcs = select({
        ":darwin": ["@cargo_darwin_x86_64//:cargo"],
        ":k8": ["@cargo_linux_x86_64//:cargo"],
    }),
)
