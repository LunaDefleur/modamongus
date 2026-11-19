// Avoid Dobby header: its extern "C" block wraps system includes, which
// Apple Clang modules rejects when compiling this translation unit as C++.
// Keep only the C API declaration used by this file.
extern "C" int DobbyHook(void* address, void* replace_call, void** origin_call);
#include <mach-o/dyld.h>
#include <cstdint>
#include <cstring>
#include <atomic>
#include <dispatch/dispatch.h>

extern "C" void initModMenu();

static std::atomic_bool isWideLightEnabled{false};

// ESP is intentionally not exposed in the UI yet: this project currently has
// no validated player enumeration/world-to-screen implementation.
extern "C" void SetEspEnabled(bool) {}
extern "C" void SetWideLightEnabled(bool enabled) {
    isWideLightEnabled.store(enabled, std::memory_order_relaxed);
}

static uintptr_t getImageHeader(const char* targetName) {
    if (!targetName || !*targetName) return 0;
    const uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; ++i) {
        const char* name = _dyld_get_image_name(i);
        if (name && std::strstr(name, targetName)) {
            const auto* header = _dyld_get_image_header(i);
            return reinterpret_cast<uintptr_t>(header);
        }
    }
    return 0;
}

using CalculateLightRadiusFn = float (*)(void*, void*);
static CalculateLightRadiusFn orig_CalculateLightRadius = nullptr;
static bool hookInstalled = false;

static float hook_CalculateLightRadius(void* instance, void* player) {
    if (isWideLightEnabled.load(std::memory_order_relaxed)) {
        return 100.0f;
    }
    return orig_CalculateLightRadius ? orig_CalculateLightRadius(instance, player) : 0.0f;
}

static void setupHooksWhenReady(int retriesLeft) {
    const uintptr_t unityHeader = getImageHeader("UnityFramework");
    if (unityHeader == 0) {
        if (retriesLeft > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC),
                           dispatch_get_main_queue(), ^{
                setupHooksWhenReady(retriesLeft - 1);
            });
        }
        return;
    }

    // IMPORTANT: This offset is version-specific and has NOT been validated
    // against the user's installed Among Us binary. Do not assume it is safe.
    constexpr uintptr_t kCalculateLightRadiusOffset = 0x1C265B0;
    void* targetLight = reinterpret_cast<void*>(unityHeader + kCalculateLightRadiusOffset);
    const int result = DobbyHook(targetLight,
                                 reinterpret_cast<void*>(hook_CalculateLightRadius),
                                 reinterpret_cast<void**>(&orig_CalculateLightRadius));
    hookInstalled = (result == 0 && orig_CalculateLightRadius != nullptr);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        initModMenu();
    });
}

__attribute__((constructor))
static void initHooks() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        setupHooksWhenReady(15);
    });
}
