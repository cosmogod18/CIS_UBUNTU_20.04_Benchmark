#!/usr/bin/env bash

# List of module names to fix
module_names=("cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "squashfs" "udf")

l_mtype="fs"

module_fix() {
    local l_mname="$1"
    local l_mpname="$(echo "$l_mname" | tr '-' '_')"
    local l_mndir="$(echo "$l_mname" | tr '-' '/')"
    local l_mpath="/lib/modules/**/kernel/$l_mtype"

    module_loadable_fix() {
        # If the module is currently loadable, add "install {MODULE_NAME} /bin/false" to a file in /etc/modprobe.d
        l_loadable="$(modprobe -n -v "$l_mname")"
        if [[ $(wc -l <<< "$l_loadable") -gt 1 ]]; then
            l_loadable="$(grep -P -- "(^h*install|\b$l_mname)\b" <<< "$l_loadable")"
        fi

        if ! grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
            echo -e "\n - setting module: \"$l_mname\" to be not loadable"
            echo -e "install $l_mname /bin/false" >> "/etc/modprobe.d/$l_mpname.conf"
        fi
    }

    module_loaded_fix() {
        # If the module is currently loaded, unload the module
        if lsmod | grep -w "$l_mname" > /dev/null 2>&1; then
            echo -e "\n - unloading module \"$l_mname\""
            modprobe -r "$l_mname"
        fi
    }

    module_deny_fix() {
        # If the module isn't deny-listed, denylist the module
        if ! modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$l_mpname\b"; then
            echo -e "\n - deny listing \"$l_mname\""
            echo -e "blacklist $l_mname" >> "/etc/modprobe.d/$l_mpname.conf"
        fi
    }

    # Check if the module exists on the system
    for l_mdir in $l_mpath; do
        if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A "$l_mdir/$l_mndir")" ]; then
            echo -e "\n - module: \"$l_mname\" exists in \"$l_mdir\"\n - checking if disabled..."
            module_deny_fix
            if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
                module_loadable_fix
                module_loaded_fix
            fi
        else
            echo -e "\n - module: \"$l_mname\" doesn't exist in \"$l_mdir\"\n"
        fi
    done

    echo -e "\n - remediation of module: \"$l_mname\" complete\n"
}

# Check each module in the list
for module_name in "${module_names[@]}"; do
    module_fix "$module_name"
done
