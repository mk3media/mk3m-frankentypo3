#!/usr/bin/env bash
set -e

# Helper script for checking and updating TYPO3 core and extension packages

check_version() {
    echo "=== Current Installed TYPO3 Packages ==="
    docker compose exec web composer show "typo3/cms-*"
}

list_outdated() {
    echo "=== Outdated Direct Dependencies ==="
    docker compose exec web composer outdated -D
}

get_typo3_packages() {
    docker compose exec web php -r '
    $composer = json_decode(file_get_contents("composer.json"), true);
    $packages = [];
    foreach (($composer["require"] ?? []) as $pkg => $ver) {
        if (strpos($pkg, "typo3/cms-") === 0) {
            $packages[] = $pkg;
        }
    }
    echo implode(" ", $packages);
    '
}

perform_core_update() {
    local target_version=$1
    if [ -z "$target_version" ]; then
        echo "Error: Target version not specified (e.g., ^13.4.5 or ~13.4.0)."
        echo "Usage: $0 update-core <version>"
        exit 1
    fi

    echo "Detecting installed TYPO3 core packages in composer.json..."
    local packages=$(get_typo3_packages)
    if [ -z "$packages" ]; then
        echo "No typo3/cms-* packages found in composer.json require block."
        exit 1
    fi

    local require_args=""
    for pkg in $packages; do
        require_args="$require_args \"$pkg:$target_version\""
    done

    echo "Updating TYPO3 core packages to $target_version..."
    eval "docker compose exec web composer require $require_args --update-with-all-dependencies --no-interaction"

    echo "Flushing TYPO3 cache..."
    docker compose exec web vendor/bin/typo3 cache:flush
    echo "TYPO3 core update complete!"
}

flush_cache() {
    echo "Flushing TYPO3 caches..."
    docker compose exec web vendor/bin/typo3 cache:flush
}

case "$1" in
    check)
        check_version
        ;;
    outdated)
        list_outdated
        ;;
    update-core)
        perform_core_update "$2"
        ;;
    flush)
        flush_cache
        ;;
    *)
        echo "TYPO3 Maintenance Helper"
        echo "Usage: $0 {check|outdated|update-core <version>|flush}"
        exit 1
        ;;
esac
