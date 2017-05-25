package(default_visibility = ["//visibility:public"])

filegroup(
    name = "uncompiled_crate",
    srcs = glob(include = ["src/**/*.rs"]) + [
        "Cargo.lock",
        "Cargo.toml",
    ]
)

filegroup(
    name = "uncompiled_crate_tar",
    srcs = ["uncompiled_crate.tar.gz"]
)

