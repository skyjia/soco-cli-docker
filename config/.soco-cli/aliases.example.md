# SoCo-CLI Aliases Configuration

Aliases allow you to create shortcuts for common commands and action sequences.

## Basic Aliases

Simple one-to-one mappings:

```
p     -> play
s     -> pause
pp    -> pauseplay
v     -> volume %1
n     -> next
b     -> previous
i     -> info
st    -> state
q     -> list_queue
```

## Parameterized Aliases

Use `%1`, `%2`, etc. for arguments:

```
v     -> volume %1          Usage: v 50  (sets volume to 50)
fav   -> play_favourite %1  Usage: fav Jazz  (plays favourite named "Jazz")
```

## Action Sequences

Use `:` separator to chain multiple actions:

```
start   -> play : volume 30
stop    -> pause : volume 0
morning -> volume 25 : play_favourite "Morning Jazz" : wait_start
night   -> volume 10 : play_favourite "Sleep Playlist"
```

## Nested Aliases

Aliases can reference other aliases:

```
quick_start -> start : fav Morning  (start is another alias)
```

## Interactive Mode Usage

```bash
# Enter interactive mode
docker run -it --rm --network host skyjia/soco-cli:latest -i

# In the shell:
> alias               # List all aliases
> alias my_play play  # Create new alias
> v 50                # Use alias (sets volume to 50)
> start               # Run sequence
> push                # Save current speaker
> set Kitchen         # Change to different speaker
> pop                 # Restore saved speaker
```

## File Location

Aliases are stored in `~/.soco-cli/aliases.json` or `/config/.soco-cli/aliases.json` if mounted.

## Load/Save Aliases

```bash
# Save aliases to file
docker run --rm --network host skyjia/soco-cli:latest --save_aliases my_aliases.json

# Load aliases from file
docker run --rm --network host skyjia/soco-cli:latest --load_aliases my_aliases.json

# Overwrite existing aliases
docker run --rm --network host skyjia/soco-cli:latest --overwrite_aliases my_aliases.json
```

## Reference

See [soco-cli Aliases Documentation](https://github.com/avantrec/soco-cli#shell-aliases) for full details.