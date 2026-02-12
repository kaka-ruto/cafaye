# Cafaye Keyboard Shortcuts Specification

**Principle:** Short, memorable, one-hand-accessible shortcuts that work across all Unix systems (macOS, Linux, BSD) without conflicts.

---

## Shortcut Strategy

**Primary: Space Leader** (Double-tap Space)
- Double-tap `Space` within 300ms to open menu
- Single `Space` then letter within 500ms for direct commands
- Most natural - you're already typing
- No conflicts with shell readline, terminals, or window managers

**Secondary: Alt Shortcuts** 
- For power users who want one-handed speed
- Works alongside Space leader
- Falls back to Escape sequence if terminal doesn't support Alt

**Customizable Leader**
- Default: `Space`
- Options: `Space`, `Comma`, `Backslash`, `Escape`
- User-configurable via `~/.config/cafaye/keybindings.json`

---

## Primary Shortcuts (Space Leader)

### Open Menu
| Shortcut | Action | Notes |
|----------|--------|-------|
| `Space Space` | Open Cafaye Menu | Double-tap Space within 300ms |

### Direct Commands (Space + Letter)
| Shortcut | Action | Mnemonic |
|----------|--------|----------|
| `Space s` | Search & Install Tools | S = Search |
| `Space i` | Install | I = Install |
| `Space r` | Rebuild/Apply Changes | R = Rebuild |
| `Space d` | Doctor (Health Check) | D = Doctor |
| `Space g` | Fleet Status | G = Group/Fleet |
| `Space b` | Backup Status | B = Backup |
| `Space u` | Update System | U = Update |
| `Space y` | Sync Push/Pull | Y = sYnc |
| `Space h` | Show Keybindings Help | H = Help |
| `Space l` | View Logs | L = Logs |
| `Space f` | Find Files | F = Find |
| `Space t` | New Terminal | T = Terminal |
| `Space c` | Edit Config | C = Config |
| `Space ?` | Show All Shortcuts | ? = Help |
| `Space q` | Quit/Close | Q = Quit |

---

## Secondary Shortcuts (Alt)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Alt+M` | Open Menu | One-handed access |
| `Alt+S` | Search | One-handed |
| `Alt+I` | Install | One-handed |
| `Alt+R` | Rebuild | One-handed |
| `Alt+D` | Doctor | One-handed |
| `Alt+G` | Fleet | One-handed |
| `Alt+B` | Backup | One-handed |
| `Alt+U` | Update | One-handed |
| `Alt+Y` | Sync | One-handed |

---

## Menu Navigation

When inside the `caf` menu:

| Key | Action |
|-----|--------|
| `↑ / ↓` or `k / j` | Navigate up/down |
| `→` or `l` | Enter submenu |
| `←` or `h` | Go back |
| `Enter` | Select item |
| `Esc` or `q` | Quit/close menu |
| `/` | Search within menu |
| `?` | Show help |
| `1-9` | Quick select item N |
| `Tab` | Next section |
| `Shift+Tab` | Previous section |

---

## Leader Key Behavior

### Timing
- **Double-tap window:** 300ms (for Space Space → Menu)
- **Leader timeout:** 500ms (time to press next key after Space)
- **Visual feedback:** Prompt shows `[LEADER]` when active

### Visual Feedback
```
~ via ☕ ❯ [LEADER] _
```

### Example Usage
```
# Open menu
Space Space

# Search for tool
Space s

# Rebuild configuration  
Space r

# Check system health
Space d

# Using Alt (one hand)
Alt+R
```

---

## Edge Cases

### Typing Two Spaces
- Typed within 300ms → Opens menu
- Typed slowly (>300ms apart) → Normal two spaces
- Solution: Pause briefly between spaces when typing text

### Terminal Compatibility
- **Space leader:** Works in 100% of terminals
- **Alt shortcuts:** Works in 95% of terminals (some send Escape sequences)
- **SSH:** Both work perfectly over SSH
- **tmux:** No conflicts with tmux's prefix key navigation

### Inside Vim/Neovim
- Space leader only works in terminal mode
- Inside Vim normal mode, Space is available for Vim mappings
- Use `:terminal` or switch to terminal pane for Cafaye shortcuts

---

## User Customization

Users customize via:
```bash
caf config keybindings
```

Or edit directly:
```
~/.config/cafaye/keybindings.json
```

**Configuration Options:**
- Leader key: Space, Comma, Backslash, or Escape
- Leader timeout (default: 500ms)
- Double-tap window (default: 300ms)
- Enable/disable Alt shortcuts
- Custom shortcut mappings

---

## Conflict Avoidance

### What We Avoid
- **Ctrl combinations:** Conflict with shell readline
- **Super/Cmd:** Conflict with OS window managers  
- **Ctrl+Shift:** Often used by terminals for copy/paste
- **F-keys:** Not available on all keyboards

### Why Space Works
- Already under your thumbs while typing
- No existing terminal/shell conflicts
- Natural "pause and command" gesture
- Works identically on macOS, Linux, BSD

---

## Testing Behaviors

### Keyboard Shortcut Tests
- [ ] Double-tap Space opens menu within 300ms
- [ ] Slow double-tap (300ms+) types two spaces normally
- [ ] Space + letter triggers command within 500ms
- [ ] Prompt shows `[LEADER]` when leader is active
- [ ] Leader timeout expires correctly after 500ms
- [ ] Alt+M opens menu
- [ ] Alt+S opens search
- [ ] Alt+R triggers rebuild
- [ ] All shortcuts work over SSH
- [ ] All shortcuts work inside tmux
- [ ] Shortcuts work on both macOS and Linux
- [ ] User can customize leader key
- [ ] User can customize timeout values
- [ ] Menu navigation with arrows works
- [ ] Menu navigation with vim keys (j/k/h/l) works
- [ ] Search within menu using / key works
