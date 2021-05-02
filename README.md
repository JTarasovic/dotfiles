
## Dependencies

### Linux
- dunst
- i3
- i3status-rust
- rofi <!-- rofi calc? -->
- <!-- figure this out for osx -->
- yubioath-desktop
- DejaVuSansMono Nerd Font
- Google Noto Sans CJK
- pactl
- playerctl
- light-locker
- udiskie
- pocket-cli <!-- which one? -->
- xrdb

### OSX
```
brew install \
    chezmoi \
    coreutils \
    git \
    lastpass-cli \
    python@3.9 \
    neovim \
    starship \
    zsh-syntax-highlighting

brew tap homebrew/cask-fonts && brew install --cask font-dejavu-sans-mono-nerd-font

lpass login $USERNAME
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH" chezmoi init $USERNAME --apply
```

### all
- Alacritty
- newsboat
- neovim
- starship
- bat

### weak depends
- Firefox Developer Edition
- Firefox
- zoom
- Slack
- Spotify

