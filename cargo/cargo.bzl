def _get_dirname(short_path):
  return short_path[0:short_path.rfind('/')]

def _rust_toolchain(ctx):
  return struct(
      rustc_path = ctx.file._rustc.path,
      rustc_lib_path = ctx.files._rustc_lib[0].dirname,
      rustc_lib_short_path = _get_dirname(ctx.files._rustc_lib[0].short_path),
      rust_lib_path = ctx.files._rust_lib[0].dirname,
      cargo_path = ctx.file._cargo.path,
      rust_lib_short_path = _get_dirname(ctx.files._rust_lib[0].short_path),
      rustdoc_path = ctx.file._rustdoc.path,
      rustdoc_short_path = ctx.file._rustdoc.short_path)

def _build_cargo_command(ctx):
  """Builds the cargo command.
  Constructs the cargo command used to build the current target.
  Args:
    ctx: The ctx object for the current target.
  Return:
    String containing the cargo command
  """
  # TODO(acmcarther): This is totally butchered from rules_rust -- I think this
  # will need to live in that repo to facilitate better usage.

  # Paths to the Rust compiler and standard libraries.
  toolchain = _rust_toolchain(ctx)

  # Paths to cc (for linker) and ar
  cpp_fragment = ctx.fragments.cpp
  cc = cpp_fragment.compiler_executable
  ar = cpp_fragment.ar_executable
  # Currently, the CROSSTOOL config for darwin sets ar to "libtool". Because
  # rust uses ar-specific flags, use /usr/bin/ar in this case.
  # TODO(dzc): This is not ideal. Remove this workaround once ar_executable
  # always points to an ar binary.
  ar_str = "%s" % ar
  if ar_str.find("libtool", 0) != -1:
    ar = "/usr/bin/ar"

  return " ".join(
      [
      "LD_LIBRARY_PATH=../%s:$LD_LIBRARY_PATH" % toolchain.rustc_lib_path,
      "PKG_CONFIG_PATH=$LD_LIBRARY_PATH",
      "DYLD_LIBRARY_PATH=../%s:$DYLD_LIBRARY_PATH" % toolchain.rustc_lib_path,
      "RUSTC=$PWD/../%s" % toolchain.rustc_path,
      "RUSTDOC=$PWD/../%s" % toolchain.rustdoc_path,
      "RUST_BACKTRACE=1",
      "RUSTFLAGS=\"%s\"" % " ".join([
          "--verbose",
          "--codegen ar=%s" % ar,
          "--codegen linker=%s" % cc,
          #"--codegen link-args='%s'" % ' '.join(cpp_fragment.link_options),
          "-L all=../%s" % toolchain.rust_lib_path
        ]),
      "TMPDIR=$PWD/../tmp",
      "CARGO_HOME=$PWD/../cargo",
      "../%s" % toolchain.cargo_path,
      "build",
      "%s" % " ".join(ctx.attr.cargo_flags),
      "--%s" % ctx.attr.profile,
      ])

def _cargo_binary_impl(ctx):
    """Implementation for the cargo_binary Skylark rule."""


    crate_tar = ctx.file.crate_tar
    cargo_binary = ctx.outputs.executable
    output_dir = cargo_binary.dirname

    cmd = """
mkdir cargo
mkdir tmp
tar -xzf {crate_tar}
cd {crate_name}
{cargo_command}
cp ./target/{profile}/{crate_name} ../{output}
"""
    cmd = cmd.format(
        crate_tar = crate_tar.path,
        cargo_command = _build_cargo_command(ctx),
        crate_name = ctx.attr.name,
        output = ctx.outputs.executable.path,
        cargo_flags = " ".join(ctx.attr.cargo_flags),
        profile = ctx.attr.profile,
    )

    ctx.action(
        inputs =
            ctx.files._rustc_lib +
            ctx.files._rust_lib +
            ctx.files._crosstool + [
            ctx.file.crate_tar,
            ctx.file._cargo,
            ctx.file._rustdoc,
            ctx.file._rustc,
        ],
        outputs = [ctx.outputs.executable],
        mnemonic = "CargoBinary",
        command = cmd,
        use_default_shell_env = True,
        progress_message = "Cargo: compiling {}".format(ctx.attr.name),
    )

    return struct()


cargo_binary = rule(
    _cargo_binary_impl,
    executable = True,
    fragments = ["cpp"],
    attrs = {
        "crate_tar": attr.label(
            mandatory = True,
            single_file = True
        ),
        "cargo_flags": attr.string_list(),
        "profile": attr.string(
            default = "release",
            values = [
                "debug",
                "release",
            ],
        ),
        "_cargo" : attr.label(
            default = Label("//cargo:cargo"),
            executable = True,
            cfg = "host",
            single_file = True,
        ),
        "_rustc" : attr.label(
            default = Label("@io_bazel_rules_rust//rust:rustc"),
            executable = True,
            cfg = "host",
            single_file = True,
        ),
        "_rustc_lib": attr.label(
            default = Label("@io_bazel_rules_rust//rust:rustc_lib"),
        ),
        "_rust_lib": attr.label(
            default = Label("@io_bazel_rules_rust//rust:rust_lib"),
        ),
        "_rustdoc": attr.label(
            default = Label("@io_bazel_rules_rust//rust:rustdoc"),
            executable = True,
            cfg = "host",
            single_file = True,
        ),
        "_crosstool": attr.label(
            default = Label("//tools/defaults:crosstool")
        ),
    }
)

def _cargo_rlib_impl(ctx):
    #output = ctx.new_file(ctx.outputs.rlib.path)
    rlib_prefix = "lib%s" % ctx.attr.name
    if ctx.attr.rlib_prefix != "":
      rlib_prefix = ctx.attr.rlib_prefix

    matches = []
    for out in ctx.files.compiled_source:
        if out.basename.startswith(rlib_prefix):
            matches.append(out)

    if len(matches) == 0:
      fail("Couldn't find file starting with %s" % rlib_prefix)
    elif len(matches) > 1:
      fail("rlib_prefix \"%s\" was ambiguous, found %s" % (rlib_prefix, matches))

    out = matches[0]
    ctx.action(
        inputs = [out],
        outputs = [ctx.outputs.rlib],
        mnemonic = "ExtractRlib",
        arguments = [
            out.path,
            ctx.outputs.rlib.path,
        ],
        command = "cp $1 $2",
        progress_message = "Copying {} from cargo".format(ctx.attr.name),
        use_default_shell_env = True,
    )

    return struct(
        rust_lib = ctx.outputs.rlib,
        transitive_libs = [],
    )

cargo_rlib = rule(
    _cargo_rlib_impl,
    attrs = {
        "compiled_source": attr.label(
            mandatory = True,
        ),
        "rlib_prefix": attr.string(),
    },
    outputs = {
        "rlib": "lib%{name}_lib.rlib",
    }
)


def cargo_export(name, crate_tar, exports, visibility=None):
  #cargo_compile(
      #      name = "%s_compiled_sources".format(name),
      #  crate_tar = crate_tar,
      #  outputs = exports.values(),
      #)

    for crate_name, path in exports.values():
        cargo_rlib(
            name = name + "_" + crate_name,
            compiled_source = ":%s_compiled_sources".format(name),
            path = path,
        )
