# PSProject

Tool to create PySwiftKit based Apps

### Create a New Project

First, create a new project which will generate a `pyproject.toml` file:

```bash
#psproject init HelloWorld
uv init --package HelloWorld --python 3.13.8
```

Navigate to the new project directory:

```bash
cd HelloWorld
```

Or open it in VS Code:

```bash
code HelloWorld
```

```bash
uv add psproject --dev
```
psproject is part of the app development and should only be added in dev mode, which uv automatic enables by default.
pips added in dev group, won't be included in the macos/ios site-packages

### Configure for Kivy

The generated `pyproject.toml` will contain default configuration. To create a Kivy-based app, add Kivy to the project dependencies and configure the PSProject backends:

```toml
[project]
authors = [ { email = "foo@baz.com", name = "somebody" } ]
dependencies = [
    "kivy"
]
description = "Add your description here"
name = "helloworld"
readme = "README.md"
requires-python = ">=3.13.8"
version = "0.1.0"

[tool.psproject]
app_name = "HelloWorld"
backends = [
    "kivyschool.kivylauncher"
]
cythonized = false
extra_index = []
pip_install_app = true
```

### Create Xcode Project

Generate the Xcode project:

```bash
uv run psproject create xcode
```

### Update Site Packages

To update the Xcode project's site-packages:

```bash
uv run psproject update site-packages
```

## Additional Resources

- [PySwiftKit Wiki](https://py-swift.github.io/wiki/)
- [Setup Guide](https://py-swift.github.io/wiki/setup/)
- [Kivy Project Documentation](https://py-swift.github.io/wiki/project/kivy/create/)
- [PyProject Configuration](https://py-swift.github.io/wiki/project/kivy/pyproject-configuration/)
- [Kivy on iOS Guide](https://kivyschool.com/kivy-on-ios/)

## License

MIT License - See LICENSE file for details
