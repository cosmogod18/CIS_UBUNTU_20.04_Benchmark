## Description:
# The cramfs filesystem type is a compressed read-only Linux filesystem embedded in small footprint systems. A cramfs image can be used without having to first decompressthe image.
## Rationale:
# Removing support for unneeded filesystem types reduces the local attack surface of the system. If this filesystem type is not needed, disable it.
