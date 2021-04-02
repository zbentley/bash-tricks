
# Utilities
- Return values/callstack
- Password reader
- Interactive output detector
- Localize globals
- Localize shell options
- Trap stacking
- Verifier of euo-pipefail, posix, etc.
- Private variable name collision template-based avoidance.
- Caching system
- Inter-shell state sharing via history, cache, shm, etc.
- Bash feature probe (e.g. zsh compatibility, hash availability, etc.)

# TODOs
- BATS tests
- Explanation of avoidance of subshells
	- Perf
	- Variable mangling/quoting sadness
	- Process constraint (embedded/docker)
- Explanation of `euo pipefail` compatibility
	- Debated
	- Useful debug tool
	- Compatibility > canon