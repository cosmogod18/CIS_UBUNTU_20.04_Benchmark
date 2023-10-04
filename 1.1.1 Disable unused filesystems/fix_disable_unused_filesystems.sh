#!/usr/bin/env bash

# List of modules to fix
modules=("cramfs", "freevxfs", "jffs2", "hfs", "hfsplus", "squashfs", "udf")

l_mtype="fs"
l_mpath="/lib/modules/**/kernel/$l_mtype"

module_loadable_fix() {
    # If the module is currently loadable, add "install {MODULE_NAME} /bin/false" to a file in /etc/modprobe.d
    l_loadable="$(modprobe -n -v "$1")"
    if [[ $(wc -l <<< "$l_loadable") -gt 1 ]]; then
        l_loadable="$(grep -P -- "(^h*install|\b$1)\b" <<< "$l_loadable")"
    fi

    if ! grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
        echo -e "\n - setting module: \"$1\" to be not loadable"
        echo -e "install $1 /bin/false" >> "/etc/modprobe.d/$(echo "$1" | tr '-' '_').conf"
    fi
}

module_loaded_fix() {
    # If the module is currently loaded, unload the module
    if lsmod | grep -w "$1" > /dev/null 2>&1; then
        echo -e "\n - unloading module \"$1\""
        modprobe -r "$1"
    fi
}

module_deny_fix() {
    # If the module isn't deny-listed, denylist the module
    if ! modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$(echo "$1" | tr '-' '_')\b"; then
        echo -e "\n - deny listing \"$1\""
        echo -e "blacklist $1" >> "/etc/modprobe.d/$(echo "$1" | tr '-' '_').conf"
    fi
}

# Check each module in the list
for module in "${modules[@]}"; do
    l_mname="$module"
    l_mpname="$(echo "$module" | tr '-' '_')"
    l_mndir="$(echo "$module" | tr '-' '/')"

    # Check if the module exists on the system
    for l_mdir in $l_mpath; do
        if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A "$l_mdir/$l_mndir")" ]; then
            echo -e "\n - module: \"$module\" exists in \"$l_mdir\"\n - checking if disabled..."
            module_deny_fix "$module"
            if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
                module_loadable_fix "$module"
                module_loaded_fix "$module"
            fi
        else
            echo -e "\n - module: \"$module\" doesn't exist in \"$l_mdir\"\n"
        fi
    done

    echo -e "\n - remediation of module: \"$module\" complete\n"
done
