# Homebrew Paths

## Apple Silicon (arm64)

| Item | Path |
|------|------|
| Homebrew prefix | `/opt/homebrew` |
| Binaries | `/opt/homebrew/bin` |
| Libraries | `/opt/homebrew/lib` |
| Headers | `/opt/homebrew/include` |
| Cellar | `/opt/homebrew/Cellar` |
| Casks | `/opt/homebrew/Caskroom` |
| etc | `/opt/homebrew/etc` |
| opt (versioned symlinks) | `/opt/homebrew/opt` |

## Intel (x86_64)

| Item | Path |
|------|------|
| Homebrew prefix | `/usr/local` |
| Binaries | `/usr/local/bin` |
| Libraries | `/usr/local/lib` |
| Headers | `/usr/local/include` |
| Cellar | `/usr/local/Cellar` |
| Casks | `/usr/local/Caskroom` |
| etc | `/usr/local/etc` |
| opt (versioned symlinks) | `/usr/local/opt` |

## Detecting at Runtime

```bash
brew --prefix        # prints the correct prefix for the current architecture
brew --cellar        # prints the Cellar path
brew --repository    # prints the Homebrew repo path
```
