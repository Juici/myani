#!/usr/bin/env bash

set -e

channel() {
    if [ -n "$TRAVIS" ]; then
        if [ "$TRAVIS_RUST_VERSION" = "$CHANNEL" ]; then
            (set -x; cargo "$@")
        fi
    else
        (set -x; cargo "+$CHANNEL" "$@")
    fi
}

if [ -n "$CLIPPY" ]; then
    if [ -n "$TRAVIS" ] && ! cargo install clippy --debug --force; then
        echo "Could not compile clippy, ignoring clippy tests"
        exit
    fi

    cargo clippy -- -D clippy

    if rustup component add rustfmt-preview; then
        cargo fmt -- --write-mode=diff
    fi
else
    CHANNEL=nightly
    cargo clean
    channel build --verbose
    channel test --verbose

    CHANNEL=beta
    cargo clean
    channel build --verbose
    channel test --verbose

    CHANNEL=stable
    cargo clean
    channel build --verbose
    channel test --verbose
fi