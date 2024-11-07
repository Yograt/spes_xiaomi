#!/bin/bash

# Define color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
END="\033[0m"

# Define branches
VENDOR_BRANCH="15.0"
KERNEL_BRANCH="NaughtySilver"
HARDWARE_BRANCH="lineage-22.0"

# Function to check if a directory exists
check_and_clone() {
    local dir=$1
    local repo=$2
    local branch=$3
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}• $dir already exists. Skipping cloning...${END}"
    else
        echo -e "${GREEN}Cloning $dir from $repo (branch: ${YELLOW}$branch${GREEN})...${END}"
        git clone --depth=1 -b "$branch" "$repo" "$dir"
    fi
}

# Apply patches and check for conflicting files
echo -e "${YELLOW}Applying patches and cloning device sources...${END}"

# Remove conflicting files
echo -e "${GREEN}• Removing conflicting files...${END}"
rm -rf hardware/google/pixel/kernel_headers/Android.bp
rm -rf hardware/lineage/compat/Android.bp

# Handle legacy imsrcsd sepolicy
SEPOLICY_PATH="device/qcom/sepolicy_vndr/legacy-um/qva/vendor/bengal/legacy-ims/hal_rcsservice.te"
if [ -f "$SEPOLICY_PATH" ]; then
    echo -e "${GREEN}Switching to legacy imsrcsd sepolicy...${END}"
    cp "$SEPOLICY_PATH" device/qcom/sepolicy_vndr/legacy-um/qva/vendor/bengal/ims/hal_rcsservice.te
else
    echo -e "${YELLOW}• Missing legacy imsrcsd sepolicy file. Skipping...${END}"
fi

# Clone required repositories if not already present
check_and_clone "vendor/xiaomi/spes" "https://github.com/spes-development/vendor_xiaomi_spes" "$VENDOR_BRANCH"
check_and_clone "kernel/xiaomi/sm6225" "https://github.com/spes-development/kernel_xiaomi_sm6225" "$KERNEL_BRANCH"
check_and_clone "hardware/xiaomi" "https://github.com/LineageOS/android_hardware_xiaomi" "$HARDWARE_BRANCH"

echo -e "${YELLOW}All patches applied successfully. Device sources are ready!${END}"
