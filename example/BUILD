load(
    "@io_bazel_rules_cargo//cargo:cargo.bzl",
     "cargo_libraries",
     "cargo_rlib")

load(
    "@io_bazel_rules_rust//rust:rust.bzl",
    "rust_binary",
)

filegroup(
    name = "hello_world_source",
    srcs = ["hello_world/hello_world.tar.gz"]
)

cargo_libraries(
    name = "hello_world",
    crate_tar = "hello_world_source",
    profile = "debug",
    outs = [
        "libbitflags-ec5f3858cc5f68d3.rlib",
        "libforeign_types-d6422e6b811c828e.rlib",
        "libgcc-dabb368ac575072c.rlib",
        "liblazy_static-c89ef958c0541373.rlib",
        "liblibc-25c8b5c5b8e8e538.rlib",
        "libopenssl-31b305b079d71313.rlib",
        "libopenssl_sys-3671bf5caabb0e1f.rlib",
        "libpkg_config-723994b826d53308.rlib",
    ],
    cargo_flags =[
        "--verbose"
    ],
)

rust_binary(
    name = "hello_world0",
    srcs = ["main.rs"],
    deps = [
        ":hello_world",
    ]
)
