// First bring-up build for vibed-360-game. This is intentionally small: initialize
// xsdk's GPU/display, clear the screen, log status, and exit when Back is pressed.
// Once this runs on the console, add game logic and rendering in the frame loop.

#include <stdbool.h>
#include <stdint.h>

#include "xsdk/gpu.h"
#include "xsdk/kernel.h"
#include "xsdk/log.h"
#include "xsdk/present.h"
#include "xsdk/splash.h"

enum {
    SPLASH_MS = 1200,
    BUFFERS = 2,
    SWAP_INTERVAL = 1,
    BEGIN_TIMEOUT_MS = 5000,
    CLEAR_ARGB = 0xFF183060
};

static void run(uint32_t width, uint32_t height)
{
    (void)width;
    (void)height;

    for (;;) {
        INPUT_STATE input = {0};
        if (XamInputGetState(0, 0, &input) == ERROR_SUCCESS &&
            (input.gamepad.buttons & INPUT_GAMEPAD_BACK)) {
            return;
        }

        uint32_t address = 0;
        const NTSTATUS status = xsdk_present_begin(&address, BEGIN_TIMEOUT_MS);
        if (!NT_SUCCESS(status)) {
            xsdk_log_write("vibed360: present_begin failed: 0x%08X",
                           (unsigned)status);
            return;
        }

        // This first milestone clears the display. Drawing is added next.
        xsdk_gpu_resolve(address, width, height, CLEAR_ARGB);
        xsdk_present_end();
    }
}

int main(void)
{
    xsdk_log_write("vibed360: startup");
    const NTSTATUS splash = xsdk_splash_show(SPLASH_MS);
    if (!NT_SUCCESS(splash)) {
        xsdk_log_write("vibed360: splash failed: 0x%08X", (unsigned)splash);
    }

    NTSTATUS status = xsdk_gpu_open();
    if (!NT_SUCCESS(status)) {
        xsdk_log_write("vibed360: gpu_open failed: 0x%08X", (unsigned)status);
        return 1;
    }

    uint32_t width = 0;
    uint32_t height = 0;
    status = xsdk_present_open(XSDK_DISPLAY_720P, BUFFERS, SWAP_INTERVAL,
                               &width, &height);
    if (!NT_SUCCESS(status)) {
        xsdk_log_write("vibed360: present_open failed: 0x%08X", (unsigned)status);
        (void)xsdk_gpu_close();
        return 1;
    }

    xsdk_log_write("vibed360: display %ux%u", (unsigned)width, (unsigned)height);
    run(width, height);

    xsdk_present_close();
    status = xsdk_gpu_close();
    if (!NT_SUCCESS(status)) {
        xsdk_log_write("vibed360: gpu_close failed: 0x%08X", (unsigned)status);
    }
    xsdk_log_write("vibed360: shutdown");
    return 0;
}
