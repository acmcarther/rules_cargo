# rules_cargo

Bazel rules for when you really just have to use cargo to build something.

## Problem

You're already doing the right and proper thing and compiling your Rust code with rust_library, rust_binary, and friends from [rules_rust](https://github.com/bazelbuild/rules_rust), but you've got this dependency or library that you just gotta build with Cargo. Maybe its invoking the dark arts of build.rs, or needs a special Cargo environment variable.

`rules_cargo` provides the hacky cargo rules you need to just build something. This is the "sledgehammer" in your arsenal.

## Overview

These rules are being build as I need them, so a lot of stuff is missing.

## cargo_binary (WIP)
```
cargo_binary(name, srcs, cargo_flags)
```
This rule does not provide a `deps` -- you cannot specify the dependencies to this rule. It will pull from whatever Cargo.toml wants and thats that.

## cargo_generate_lockfile (WIP)
```
cargo_generate_lockfile(name, cargo_toml)
```
