CARGO_BUILD_FILE = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "cargo",
    srcs = ["cargo/bin/cargo"],
    visibility = ["//visibility:public"],
)
"""

def cargo_repositories():
    native.new_http_archive(
        name = "cargo_linux_x86_64",
        url = "https://static.rust-lang.org/dist/cargo-0.16.0-x86_64-unknown-linux-gnu.tar.gz",
        strip_prefix = "cargo-nightly-x86_64-unknown-linux-gnu",
        sha256 = "0655713cacab054e8e5a33e742081eebec8531a8c77d28a4294e6496123e8ab1",
        build_file_content = CARGO_BUILD_FILE,
    )

    # TODO(acmcarther): This SHA isn't correct
    native.new_http_archive(
        name = "cargo_darwin_x86_64",
        url = "https://static.rust-lang.org/dist/cargo-0.16.0-x86_64-apple-darwin.tar.gz",
        strip_prefix = "cargo-0.16.0-x86_64-apple-darwin",
        sha256 = "38606e464b31a778ffa7d25d490a9ac53b472102bad8445b52e125f63726ac64",
        build_file_content = CARGO_BUILD_FILE,
    )
