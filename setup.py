"""
Setup script for PSProject.

Downloads the pre-built macOS universal binary from GitHub Releases
and installs it to the bin directory (e.g. .venv/bin/psproject).
"""

import os
import sys
import tarfile
import urllib.request
from io import BytesIO

from setuptools import setup
from setuptools.command.build import build

VERSION = "1.0.5"
REPO = "Py-Swift/PSProject"
BINARY_URL = f"https://github.com/{REPO}/releases/download/{VERSION}/PSProject.tar.gz"

SCRIPT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "psproject")


class BuildWithDownload(build):
    """Override build to download the pre-built binary before the wheel is assembled."""

    def run(self):
        if sys.platform != "darwin":
            raise RuntimeError(
                "PSProject is only available for macOS. "
                "See https://github.com/Py-Swift/PSProject for details."
            )

        print(f"Downloading PSProject {VERSION} from {BINARY_URL} ...")
        response = urllib.request.urlopen(BINARY_URL)
        with tarfile.open(fileobj=BytesIO(response.read()), mode="r:gz") as tar:
            for member in tar.getmembers():
                if os.path.basename(member.name) == "PSProject" and member.isfile():
                    data = tar.extractfile(member).read()
                    with open(SCRIPT_PATH, "wb") as fh:
                        fh.write(data)
                    os.chmod(SCRIPT_PATH, 0o755)
                    break
            else:
                raise RuntimeError("PSProject binary not found in the release archive")

        super().run()


setup(
    data_files=[("bin", ["psproject"])],
    cmdclass={"build": BuildWithDownload},
)
