# rules_cargo

Bazel rules for when you really just have to use cargo to build something.

## Problem

You're already doing the right and proper thing and compiling your Rust code with rust_library, rust_binary, and friends from [rules_rust](https://github.com/bazelbuild/rules_rust), but you've got this dependency or library that you just gotta build with Cargo. Maybe its invoking the dark arts of build.rs, or needs a special Cargo environment variable.

`rules_cargo` provides the hacky cargo rules you need to just build something. This is the "sledgehammer" in your arsenal.

## Overview

Currently rules_cargo supplies two rules:

### cargo_libraries
```python
cargo_libraries(
    name = "cargo_libraries",
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
```
Take a tarball containing a rust crate, and compile it with cargo, exporting the specified rlibs.

You'll probably want to export *all* of the rlibs that are generated, as `rustc` requires the full set of transitive dependencies.

### cargo_rlib
```python
cargo_rlib(
    name = "libc",
    compiled_source = ":cargo_libraries",
)
```
Take the result of a cargo_libraries call and export the named crate compatibly with `rules_rust` Skylark rules.

This step takes the generated rlibs, and constructs a Provider of the same shape as what would be output by a `rust_library`.

## Examples

[test/precompiled_crate](./test) (see BUILD) demonstrates usage in a situation where rlibs are already available.
[test/uncompiled_crate](./test) (see BUILD) demonstrates usage in a situation where rlibs are furnished by `cargo build`.

[example/hello_world](./example/hello_world) demonstrates usage in a "real-ish" scenario. It's currently broken due to linker issues. See below for more info.

## TODOs

Handle dynamically linked transitive dependencies. An example is openssl: compiling a crate containing openssl will successfully produce an `openssl` rlib that you can export, but any `rust_library` that try to depend on it will fail to locate the libraries that are being linked in.

Full text of an external discussion:

```
One thing I've been pursuing lately is a cargo_libraries type rule that supplies a list of libraries as declared from a cargo toml, building them in a shared environment.

So far, this approach has been sufficient in generating a list of rlibs which can be surfaced for conventional rust_library or rust_binary rules. However, I've hit a sticking point: linking upstream dynamic dependencies. Heres an example:

cargo_libraries("cargo_workspace") is depended on by
cargo_rlib("openssl")              is depended on by
rust_library("bazel_lib")


cargo_libraries produces a series of ordinary rlibs from the result of a `cargo build` execution. cargo_rlib surfaces one rlib from that execution, as a rust_library compatible provider, and supplies the necessary transitive_dependencies. Finally, any ordinary rust_library can depend on that cargo_rlib as if it was another rust_library.

My issue comes in on the build of rust_library("bazel_lib"): the rust rule attempts to link against crypto and ssl due to the upstream openssl dependency, which would be available, but the rust_library (and all other rust rules rules) clobbers ld_library_path. To be clear, cargo compiles the openssl crate just fine, but some linking dependencies remain -- which downstream rlibs detect and attempt to link in as well. At this point I've hit the end of my background, and I'm hoping you might have some ideas.
```
