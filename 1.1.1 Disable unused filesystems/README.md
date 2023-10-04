# 1.1.1 Disable unused filesystems
A number of uncommon filesystem types are supported under Linux. Removing support
for unneeded filesystem types reduces the local attack surface of the system. If a
filesystem type is not needed it should be disabled. Native Linux file systems are
designed to ensure that built-in security controls function as expected. Non-native
filesystems can lead to unexpected consequences to both the security and functionality
of the system and should be used with caution. Many filesystems are created for niche
use cases and are not maintained and supported as the operating systems are updated
and patched. Users of non-native filesystems should ensure that there is attention and
ongoing support for them, especially in light of frequent operating system changes



# 1.1.1.1 Ensure mounting of cramfs filesystems is disabled 
## Description:
The cramfs filesystem type is a compressed read-only Linux filesystem embedded in small footprint systems. A cramfs image can be used without having to first decompressthe image.
## Rationale:
Removing support for unneeded filesystem types reduces the local attack surface of the system. If this filesystem type is not needed, disable it.

# 1.1.1.2 Ensure mounting of freevxfs filesystems is disabled 
## Description:
The freevxfs filesystem type is a free version of the Veritas type filesystem. This is the primary filesystem type for HP-UX operating systems.
## Rationale:
Removing support for unneeded filesystem types reduces the local attack surface of the system. If this filesystem type is not needed, disable it.

# 1.1.1.3 Ensure mounting of jffs2 filesystems is disabled 
## Description:
The jffs2 (journaling flash filesystem 2) filesystem type is a log-structured filesystem used in flash memory devices.
## Rationale:
Removing support for unneeded filesystem types reduces the local attack surface of the system. If this filesystem type is not needed, disable it.

