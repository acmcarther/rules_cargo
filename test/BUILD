load(
    "//cargo:cargo.bzl",
    "cargo_rlib",
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
