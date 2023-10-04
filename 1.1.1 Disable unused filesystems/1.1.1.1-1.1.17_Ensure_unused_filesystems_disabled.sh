#!/usr/bin/env bash

# List of modules to check
modules=("hfs" "cramfs" "hfsplus")

# Initialize variables
l_output=""
l_output2=""
l_output3=""
l_dl=""
l_mtype="fs"
l_searchloc="/lib/modprobe.d/*.conf /usr/local/lib/modprobe.d/*.conf /run/modprobe.d/*.conf /etc/modprobe.d/*.conf"

module_loadable_chk() {
    # Check if the module is currently loadable
    l_loadable="$(modprobe -n -v "$1")"
    if [[ $(wc -l <<< "$l_loadable") -gt 1 ]]; then
        l_loadable="$(grep -P -- "(^\h*install|\b$1)\b" <<< "$l_loadable")"
    fi

    if grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
        l_output="$l_output\n - module: \"$1\" is not loadable: \"$l_loadable\""
    else
        l_output2="$l_output2\n - module: \"$1\" is loadable: \"$l_loadable\""
    fi
}

module_loaded_chk() {
    # Check if the module is currently loaded
    if ! lsmod | grep -w "$1" > /dev/null 2>&1; then
        l_output="$l_output\n - module: \"$1\" is not loaded"
    else
        l_output2="$l_output2\n - module: \"$1\" is loaded"
    fi
}

module_deny_chk() {
    # Check if the module is deny-listed
    l_dl="y"
    local mpname="$(tr '-' '_' <<< "$1")"
    if modprobe --showconfig | grep -Pq -- '^\h*blacklist\h+'"$mpname"'\b'; then
        l_output="$l_output\n - module: \"$1\" is deny listed in: \"$(grep -Pls -- "^\h*blacklist\h+$mpname\b" $l_searchloc)\""
    else
        l_output2="$l_output2\n - module: \"$1\" is not deny listed"
    fi
}

# Check each module in the list
for module in "${modules[@]}"; do
    l_output=""
    l_output2=""
    l_output3=""
    l_dl=""
    l_mname="$module"
    l_mpath="/lib/modules/**/kernel/$l_mtype"
    l_mndir="$(tr '-' '/' <<< "$l_mname")"

    # Check if the module exists on the system
    for l_mdir in $l_mpath; do
        if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A "$l_mdir/$l_mndir")" ]; then
            l_output3="$l_output3\n - \"$l_mdir\""
            [ "$l_dl" != "y" ] && module_deny_chk "$module"
            if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
                module_loadable_chk "$module"
                module_loaded_chk "$module"
            fi
        else
            l_output="$l_output\n - module: \"$module\" doesn't exist in \"$l_mdir\""
        fi
    done

    # Report results for each module
    if [ -n "$l_output3" ]; then
        echo -e "\n\n -- INFO --\n - module: \"$module\" exists in:$l_output3"
    fi

    if [ -z "$l_output2" ]; then
        echo -e "\n- Audit Result for module \"$module\":\n ** PASS **\n$l_output\n"
    else
        echo -e "\n- Audit Result for module \"$module\":\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
        [ -n "$l_output" ] && echo -e "\n- Correctly set:\n$l_output\n"
    fi
done
