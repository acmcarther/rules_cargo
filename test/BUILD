load(
    "//cargo:cargo.bzl",
    "cargo_rlib",
    "cargo_libraries",
)

load(
    # TODO(acmcarther): Remove the fork of test_rules when the fixed version is released.
    #"@bazel_tools//tools/build_rules:test_rules.bzl",
    ":test_rules.bzl",
    "rule_test",
)


cargo_rlib(
    name = "url",
    compiled_source = "//test/precompiled_crate",
)

cargo_rlib(
    name = "libc",
    compiled_source = "//test/precompiled_crate",
)

rule_test(
    name = "cargo_rlib_url_test",
    generates = ["liburl_lib.rlib"],
    provides = {
        "rust_lib": "/liburl_lib.rlib$",
        "transitive_libs": "^\\[\\]$"
    },
    rule = ":url",
)

rule_test(
    name = "cargo_rlib_libc_test",
    generates = ["liblibc_lib.rlib"],
    provides = {
        "rust_lib": "/liblibc_lib.rlib$",
        "transitive_libs": "^\\[\\]$"
    },
    rule = ":libc",
)

cargo_libraries(
    name = "debug_libs",
    crate_tar = "//test/uncompiled_crate:uncompiled_crate_tar",
    profile = "debug",
    outs = [
        "libnom-f508bbf6b555f7d6.rlib",
        "librustc_serialize-fd42b279cd96bacb.rlib",
        "libitertools-10601d5412654766.rlib",
    ],
    cargo_flags =[
        "--verbose"
    ],
)
rule_test(
    name = "cargo_debug_libs_test",
    generates = [
        "libnom-f508bbf6b555f7d6.rlib",
        "librustc_serialize-fd42b279cd96bacb.rlib",
        "libitertools-10601d5412654766.rlib",
    ],
    rule = ":debug_libs",
)
