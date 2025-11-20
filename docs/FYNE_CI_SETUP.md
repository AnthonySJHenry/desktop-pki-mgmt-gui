### Fyne CI/CD Setup Required Critical Dependencies

#### The Problem
Fyne apps fail to build in CI with cryptic errors like:
- `no export data for "fyne.io/fyne/v2/app"`
- `fatal error: X11/Xlib.h: No such file or directory`
- `Package 'gl' was not found in the pkg-config search path`

#### The Solution
For GitHub Actions (Ubuntu runners), you MUST install these system packages:

```yaml
- name: Install GUI dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y libgl1-mesa-dev xorg-dev
