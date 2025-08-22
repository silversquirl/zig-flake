# shellcheck shell=bash

zigSetEnvVars() {
    ZIG_GLOBAL_CACHE_DIR=$(mktemp -d zig-cache.XXX)
    export ZIG_GLOBAL_CACHE_DIR ZIG_LOCAL_CACHE_DIR="$ZIG_GLOBAL_CACHE_DIR"
}

zigAddDefaultFlags() {

    local buildCores=1

    # Parallel building is enabled by default.
    if [ "${enableParallelBuilding-1}" ]; then
        buildCores="$NIX_BUILD_CORES"
    fi

    flagsArray+=(
        ${zigDeps:+--system "$zigDeps"}
        "-j$buildCores"
        -Dcpu="${zigCpuTarget:-baseline}"
    )
}

zigBuildPhase() {
    runHook preBuild

    local flagsArray=(
        --release="${zigReleaseMode:-any}"
    )
    zigAddDefaultFlags
    concatTo flagsArray zigFlags zigFlagsArray

    echoCmd 'build flags' "${flagsArray[@]}"
    TERM=dumb zig build "${flagsArray[@]}"

    runHook postBuild
}

zigCheckPhase() {
    runHook preCheck

    local flagsArray=()
    zigAddDefaultFlags
    concatTo flagsArray zigFlags zigFlagsArray checkTarget=test

    echoCmd 'check flags' "${flagsArray[@]}"
    TERM=dumb zig build "${flagsArray[@]}"

    runHook postCheck
}

zigInstallPhase() {
    runHook preInstall

    # shellcheck disable=SC2154
    mkdir -p "$prefix"
    mv -t "$prefix" zig-out/*

    runHook postInstall
}

# shellcheck disable=SC2154
addEnvHooks "$targetOffset" zigSetEnvVars

if [ -z "${dontUseZigBuild-}" ] && [ -z "${buildPhase-}" ]; then
    buildPhase=zigBuildPhase
fi

if [ -z "${dontUseZigCheck-}" ] && [ -z "${checkPhase-}" ]; then
    checkPhase=zigCheckPhase
fi

if [ -z "${dontUseZigInstall-}" ] && [ -z "${installPhase-}" ]; then
    installPhase=zigInstallPhase
fi
