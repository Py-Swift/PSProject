"""Setup script for PSProject.

Builds the Swift package and bundles the binary into the wheel.
When installed, the binary ends up in bin/ (e.g. .venv/bin/psproject).
"""

import os
import platform
import re
import shutil
import subprocess
import sys

from setuptools import setup, Distribution
from setuptools.command.build import build
from wheel.bdist_wheel import bdist_wheel

ROOT = os.path.dirname(os.path.abspath(__file__))
BINARY_DEST = os.path.join(ROOT, "psproject")


def _get_version():
    """Read the version from pyproject.toml."""
    with open(os.path.join(ROOT, "pyproject.toml")) as f:
        for line in f:
            m = re.match(r'^version\s*=\s*"(.+?)"', line)
            if m:
                return m.group(1)
    raise RuntimeError("Could not find version in pyproject.toml")


VERSION = _get_version()


class BinaryDistribution(Distribution):
    """Force a platform-specific wheel even without compiled extensions."""

    def has_ext_modules(self):
        return True


class PlatformWheel(bdist_wheel):
    """Tag wheel as py3-none with the correct macOS arch."""

    def get_tag(self):
        _, _, plat = super().get_tag()

        # Derive the correct arch from PSPROJECT_ARCHS
        archs = os.environ.get("PSPROJECT_ARCHS", "").split()
        if not archs:
            archs = [platform.machine()]

        if set(archs) == {"x86_64", "arm64"} or set(archs) == {"arm64", "x86_64"}:
            arch = "universal2"
        elif len(archs) == 1:
            arch = archs[0]
        else:
            arch = archs[0]

        # Replace the arch suffix in the platform tag
        # e.g. macosx_10_9_x86_64 -> macosx_10_9_arm64
        parts = plat.rsplit("_", 1)
        if plat.startswith("macosx_") and len(parts) == 2:
            # Handle tags like macosx_10_9_x86_64 (arch is last part)
            # or macosx_10_9_universal2
            base = plat.split("_")
            # base = ['macosx', '10', '9', 'x86', '64'] or ['macosx', '10', '9', 'arm64']
            # Reconstruct: macosx_MAJOR_MINOR_ARCH
            plat = f"macosx_{base[1]}_{base[2]}_{arch}"

        return "py3", "none", plat


def _swift_build(arch):
    """Run swift build for the given architecture and return the binary path."""
    cmd = [
        "swift", "build",
        "-c", "release",
        "--disable-sandbox",
        "--arch", arch,
        "--product", "PSProject",
    ]
    print(f"Running: {' '.join(cmd)}")
    subprocess.check_call(cmd, cwd=ROOT)
    return os.path.join(ROOT, ".build", f"{arch}-apple-macosx", "release", "PSProject")


class SwiftBuild(build):
    """Build the Swift binary and place it where setuptools will pick it up."""

    def run(self):
        if sys.platform != "darwin":
            raise RuntimeError(
                "PSProject is only available for macOS. "
                "See https://github.com/Py-Swift/PSProject for details."
            )

        # Set the Swift CLI version from pyproject.toml
        print(f"Setting PSProject version to {VERSION} ...")
        subprocess.check_call(
            [
                "swift", "package", "plugin",
                "--allow-writing-to-package-directory",
                "SetVersion", "--target", "PSProject", VERSION,
            ],
            cwd=ROOT,
        )

        archs = os.environ.get("PSPROJECT_ARCHS", "").split()
        if not archs:
            # Default: build for the current machine architecture
            archs = [platform.machine()]

        binaries = [_swift_build(arch) for arch in archs]

        if len(binaries) == 1:
            shutil.copy2(binaries[0], BINARY_DEST)
        else:
            # Create a universal binary
            subprocess.check_call(
                ["lipo", "-create"] + binaries + ["-output", BINARY_DEST]
            )

        os.chmod(BINARY_DEST, 0o755)
        print(f"Built PSProject binary: {BINARY_DEST}")

        super().run()


setup(
    data_files=[("bin", ["psproject"])],
    distclass=BinaryDistribution,
    cmdclass={"build": SwiftBuild, "bdist_wheel": PlatformWheel},
)
