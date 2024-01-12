const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("main", .{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addStaticLibrary(.{
        .name = "SDL3",
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibC();

    lib.addIncludePath(.{ .path = "c-src/include/" });
    lib.addIncludePath(.{ .path = "c-src/src/" });
    lib.addIncludePath(.{ .path = "c-src/src/video/khronos/" });

    const flags = &[_][]const u8{"-std=c99"};

    lib.addCSourceFiles(.{
        .files = &(files.root ++
            files.atomic.general ++
            files.audio.general ++
            files.core.general ++
            files.cpu_info.general ++
            files.dynapi.general ++
            files.events.general ++
            files.file.general ++
            files.haptic.general ++
            files.hidapi.general ++
            files.joystick.general ++
            files.libm.general ++
            files.locale.general ++
            files.main.general ++
            files.misc.general ++
            files.power.general ++
            files.render.general ++
            files.sensor.general ++
            files.stdlib.general ++
            files.thread.general ++
            files.timer.general ++
            files.video.general),

        .flags = flags,
    });

    switch (target.result.os.tag) {
        .windows => {
            lib.addCSourceFiles(.{
                .files = &(files.audio.windows ++
                    files.core.windows ++
                    files.filesystem.windows ++
                    files.haptic.windows ++
                    files.joystick.windows ++
                    files.loadso.windows ++
                    files.locale.windows ++
                    files.misc.windows ++
                    files.power.windows ++
                    files.render.windows ++
                    files.sensor.windows ++
                    files.thread.windows ++
                    files.timer.windows ++
                    files.video.windows),

                .flags = flags,
            });

            module.linkSystemLibrary("setupapi", .{});
            module.linkSystemLibrary("winmm", .{});
            module.linkSystemLibrary("imm32", .{});
            module.linkSystemLibrary("version", .{});
            module.linkSystemLibrary("opengl32", .{});
            module.linkSystemLibrary("gdi32", .{});
            module.linkSystemLibrary("ole32", .{});
            module.linkSystemLibrary("oleaut32", .{});
        },

        else => return error.OSNotSupported,
    }

    module.linkLibrary(lib);
}

const root = "c-src/src/";

const files = .{
    .atomic = .{
        .general = [_][]const u8{
            root ++ "atomic/SDL_atomic.c",
            root ++ "atomic/SDL_spinlock.c",
        },
    },

    .audio = .{
        .macos = [_][]const u8{
            root ++ "audio/coreaudio/SDL_coreaudio.m",
        },

        .linux = [_][]const u8{
            root ++ "audio/jack/SDL_jackaudio.c",
            root ++ "audio/alsa/SDL_alsa_audio.c",
            root ++ "audio/pipewire/SDL_pipewire.c",
            root ++ "audio/pulseaudio/SDL_pulseaudio.c",
        },

        .windows = [_][]const u8{
            root ++ "audio/directsound/SDL_directsound.c",
            root ++ "audio/wasapi/SDL_wasapi.c",
            root ++ "audio/wasapi/SDL_wasapi_win32.c",
        },

        .general = [_][]const u8{
            root ++ "audio/SDL_audio.c",
            root ++ "audio/SDL_audiocvt.c",
            root ++ "audio/SDL_audiodev.c",
            root ++ "audio/SDL_audioqueue.c",
            root ++ "audio/SDL_audioresample.c",
            root ++ "audio/SDL_audiotypecvt.c",
            root ++ "audio/SDL_mixer.c",
            root ++ "audio/SDL_wave.c",
            root ++ "audio/disk/SDL_diskaudio.c",
            root ++ "audio/dummy/SDL_dummyaudio.c",
        },
    },

    .core = .{
        .linux = [_][]const u8{
            root ++ "core/linux/SDL_dbus.c",
            root ++ "core/linux/SDL_evdev.c",
            root ++ "core/linux/SDL_evdev_capabilities.c",
            root ++ "core/linux/SDL_evdev_kbd.c",
            root ++ "core/linux/SDL_fcitx.c",
            root ++ "core/linux/SDL_ibus.c",
            root ++ "core/linux/SDL_ime.c",
            root ++ "core/linux/SDL_sandbox.c",
            root ++ "core/linux/SDL_system_theme.c",
            root ++ "core/linux/SDL_threadprio.c",
            root ++ "core/linux/SDL_udev.c",
        },

        .unix = [_][]const u8{
            root ++ "core/unix/SDL_appid.c",
            root ++ "core/unix/SDL_poll.c",
        },

        .windows = [_][]const u8{
            root ++ "core/windows/SDL_hid.c",
            root ++ "core/windows/SDL_immdevice.c",
            root ++ "core/windows/SDL_windows.c",
            root ++ "core/windows/SDL_xinput.c",
        },

        .general = [_][]const u8{
            root ++ "core/SDL_core_unsupported.c",
            root ++ "core/SDL_runapp.c",
        },
    },

    .cpu_info = .{
        .general = [_][]const u8{
            root ++ "cpuinfo/SDL_cpuinfo.c",
        },
    },

    .dynapi = .{
        .general = [_][]const u8{
            root ++ "dynapi/SDL_dynapi.c",
        },
    },

    .events = .{
        .general = [_][]const u8{
            root ++ "events/imKStoUCS.c",
            root ++ "events/SDL_clipboardevents.c",
            root ++ "events/SDL_displayevents.c",
            root ++ "events/SDL_dropevents.c",
            root ++ "events/SDL_events.c",
            root ++ "events/SDL_keyboard.c",
            root ++ "events/SDL_keysym_to_scancode.c",
            root ++ "events/SDL_mouse.c",
            root ++ "events/SDL_pen.c",
            root ++ "events/SDL_quit.c",
            root ++ "events/SDL_scancode_tables.c",
            root ++ "events/SDL_touch.c",
            root ++ "events/SDL_windowevents.c",
        },
    },

    .file = .{
        .macos = [_][]const u8{
            root ++ "file/cocoa/SDL_rwopsbundlesupport.m",
        },

        .general = [_][]const u8{
            root ++ "file/SDL_rwops.c",
        },
    },

    .filesystem = .{
        .macos = [_][]const u8{
            root ++ "filesystem/cocoa/SDL_sysfilesystem.m",
        },

        .dummy = [_][]const u8{
            root ++ "filesystem/dummy/SDL_sysfilesystem.c",
        },

        .unix = [_][]const u8{
            root ++ "filesystem/unix/SDL_sysfilesystem.c",
        },

        .windows = [_][]const u8{
            root ++ "filesystem/windows/SDL_sysfilesystem.c",
        },
    },

    .haptic = .{
        .macos = [_][]const u8{
            root ++ "haptic/darwin/SDL_syshaptic.c",
        },

        .dummy = [_][]const u8{
            root ++ "haptic/dummy/SDL_syshaptic.c",
        },

        .linux = [_][]const u8{
            root ++ "haptic/linux/SDL_syshaptic.c",
        },

        .windows = [_][]const u8{
            root ++ "haptic/windows/SDL_dinputhaptic.c",
            root ++ "haptic/windows/SDL_windowshaptic.c",
            root ++ "haptic/windows/SDL_xinputhaptic.c",
        },

        .general = [_][]const u8{
            root ++ "haptic/SDL_haptic.c",
        },
    },

    .hidapi = .{
        .general = [_][]const u8{
            root ++ "hidapi/SDL_hidapi.c",
        },
    },

    .joystick = .{
        .macos = [_][]const u8{
            root ++ "joystick/apple/SDL_mfijoystick.m",
            root ++ "joystick/darwin/SDL_iokitjoystick.c",
        },

        .dummy = [_][]const u8{
            root ++ "joystick/dummy/SDL_sysjoystick.c",
        },

        .linux = [_][]const u8{
            root ++ "joystick/linux/SDL_sysjoystick.c",
        },

        .windows = [_][]const u8{
            root ++ "joystick/windows/SDL_dinputjoystick.c",
            root ++ "joystick/windows/SDL_rawinputjoystick.c",
            root ++ "joystick/windows/SDL_windowsjoystick.c",
            root ++ "joystick/windows/SDL_windows_gaming_input.c",
            root ++ "joystick/windows/SDL_xinputjoystick.c",
        },

        .general = [_][]const u8{
            root ++ "joystick/virtual/SDL_virtualjoystick.c",
            root ++ "joystick/hidapi/SDL_hidapijoystick.c",
            root ++ "joystick/hidapi/SDL_hidapi_combined.c",
            root ++ "joystick/hidapi/SDL_hidapi_gamecube.c",
            root ++ "joystick/hidapi/SDL_hidapi_luna.c",
            root ++ "joystick/hidapi/SDL_hidapi_ps3.c",
            root ++ "joystick/hidapi/SDL_hidapi_ps4.c",
            root ++ "joystick/hidapi/SDL_hidapi_ps5.c",
            root ++ "joystick/hidapi/SDL_hidapi_rumble.c",
            root ++ "joystick/hidapi/SDL_hidapi_shield.c",
            root ++ "joystick/hidapi/SDL_hidapi_stadia.c",
            root ++ "joystick/hidapi/SDL_hidapi_steam.c",
            root ++ "joystick/hidapi/SDL_hidapi_steamdeck.c",
            root ++ "joystick/hidapi/SDL_hidapi_switch.c",
            root ++ "joystick/hidapi/SDL_hidapi_wii.c",
            root ++ "joystick/hidapi/SDL_hidapi_xbox360.c",
            root ++ "joystick/hidapi/SDL_hidapi_xbox360w.c",
            root ++ "joystick/hidapi/SDL_hidapi_xboxone.c",
            root ++ "joystick/controller_type.c",
            root ++ "joystick/SDL_gamepad.c",
            root ++ "joystick/SDL_joystick.c",
            root ++ "joystick/SDL_steam_virtual_gamepad.c",
        },
    },

    .libm = .{
        .general = [_][]const u8{
            root ++ "libm/e_atan2.c",
            root ++ "libm/e_exp.c",
            root ++ "libm/e_fmod.c",
            root ++ "libm/e_log.c",
            root ++ "libm/e_log10.c",
            root ++ "libm/e_pow.c",
            root ++ "libm/e_rem_pio2.c",
            root ++ "libm/e_sqrt.c",
            root ++ "libm/k_cos.c",
            root ++ "libm/k_rem_pio2.c",
            root ++ "libm/k_sin.c",
            root ++ "libm/k_tan.c",
            root ++ "libm/s_atan.c",
            root ++ "libm/s_copysign.c",
            root ++ "libm/s_cos.c",
            root ++ "libm/s_fabs.c",
            root ++ "libm/s_floor.c",
            root ++ "libm/s_modf.c",
            root ++ "libm/s_scalbn.c",
            root ++ "libm/s_sin.c",
            root ++ "libm/s_tan.c",
        },
    },

    .loadso = .{
        .dummy = [_][]const u8{
            root ++ "loadso/dummy/SDL_sysloadso.c",
        },

        .dlopen = [_][]const u8{
            root ++ "loadso/dlopen/SDL_sysloadso.c",
        },

        .windows = [_][]const u8{
            root ++ "loadso/windows/SDL_sysloadso.c",
        },
    },

    .locale = .{
        .dummy = [_][]const u8{
            root ++ "locale/dummy/SDL_syslocale.c",
        },

        .macos = [_][]const u8{
            root ++ "locale/macos/SDL_syslocale.m",
        },

        .unix = [_][]const u8{
            root ++ "locale/unix/SDL_syslocale.c",
        },

        .windows = [_][]const u8{
            root ++ "locale/windows/SDL_syslocale.c",
        },

        .general = [_][]const u8{
            root ++ "locale/SDL_locale.c",
        },
    },

    .main = .{
        .general = [_][]const u8{
            root ++ "main/generic/SDL_sysmain_callbacks.c",
            root ++ "main/SDL_main_callbacks.c",
        },
    },

    .misc = .{
        .dummy = [_][]const u8{
            root ++ "misc/dummy/SDL_sysurl.c",
        },

        .macos = [_][]const u8{
            root ++ "misc/macos/SDL_sysurl.m",
        },

        .unix = [_][]const u8{
            root ++ "misc/unix/SDL_sysurl.c",
        },

        .windows = [_][]const u8{
            root ++ "misc/windows/SDL_sysurl.c",
        },

        .general = [_][]const u8{
            root ++ "misc/SDL_url.c",
        },
    },

    .power = .{
        .linux = [_][]const u8{
            root ++ "power/linux/SDL_syspower.c",
        },

        .macos = [_][]const u8{
            root ++ "power/macos/SDL_syspower.c",
        },

        .windows = [_][]const u8{
            root ++ "power/windows/SDL_syspower.c",
        },

        .general = [_][]const u8{
            root ++ "power/SDL_power.c",
        },
    },

    .render = .{
        .windows = [_][]const u8{
            root ++ "render/direct3d/SDL_render_d3d.c",
            root ++ "render/direct3d/SDL_shaders_d3d.c",
            root ++ "render/direct3d11/SDL_render_d3d11.c",
            root ++ "render/direct3d11/SDL_shaders_d3d11.c",
            root ++ "render/direct3d12/SDL_render_d3d12.c",
            root ++ "render/direct3d12/SDL_shaders_d3d12.c",
            root ++ "render/opengl/SDL_render_gl.c",
            root ++ "render/opengl/SDL_shaders_gl.c",
            root ++ "render/opengles2/SDL_render_gles2.c",
            root ++ "render/opengles2/SDL_shaders_gles2.c",
        },

        .macos = [_][]const u8{
            root ++ "render/metal/SDL_render_metal.m",
            root ++ "render/opengl/SDL_render_gl.c",
            root ++ "render/opengl/SDL_shaders_gl.c",
            root ++ "render/opengles2/SDL_render_gles2.c",
            root ++ "render/opengles2/SDL_shaders_gles2.c",
        },

        .linux = [_][]const u8{
            root ++ "render/opengl/SDL_render_gl.c",
            root ++ "render/opengl/SDL_shaders_gl.c",
            root ++ "render/opengles2/SDL_render_gles2.c",
            root ++ "render/opengles2/SDL_shaders_gles2.c",
        },

        .general = [_][]const u8{
            root ++ "render/SDL_d3dmath.c",
            root ++ "render/SDL_render.c",
            root ++ "render/SDL_render_unsupported.c",
            root ++ "render/SDL_yuv_sw.c",
            root ++ "render/software/SDL_blendfillrect.c",
            root ++ "render/software/SDL_blendline.c",
            root ++ "render/software/SDL_blendpoint.c",
            root ++ "render/software/SDL_drawline.c",
            root ++ "render/software/SDL_drawpoint.c",
            root ++ "render/software/SDL_render_sw.c",
            root ++ "render/software/SDL_rotate.c",
            root ++ "render/software/SDL_triangle.c",
        },
    },

    .sensor = .{
        .dummy = [_][]const u8{
            root ++ "sensor/dummy/SDL_dummysensor.c",
        },

        .windows = [_][]const u8{
            root ++ "sensor/windows/SDL_windowssensor.c",
        },

        .general = [_][]const u8{
            root ++ "sensor/SDL_sensor.c",
        },
    },

    .stdlib = .{
        .general = [_][]const u8{
            root ++ "stdlib/SDL_crc16.c",
            root ++ "stdlib/SDL_crc32.c",
            root ++ "stdlib/SDL_getenv.c",
            root ++ "stdlib/SDL_iconv.c",
            root ++ "stdlib/SDL_malloc.c",
            root ++ "stdlib/SDL_mslibc.c",
            root ++ "stdlib/SDL_qsort.c",
            root ++ "stdlib/SDL_stdlib.c",
            root ++ "stdlib/SDL_string.c",
            root ++ "stdlib/SDL_strtokr.c",
        },
    },

    .thread = .{
        .pthread = [_][]const u8{
            root ++ "thread/pthread/SDL_syscond.c",
            root ++ "thread/pthread/SDL_sysmutex.c",
            root ++ "thread/pthread/SDL_sysrwlock.c",
            root ++ "thread/pthread/SDL_syssem.c",
            root ++ "thread/pthread/SDL_systhread.c",
            root ++ "thread/pthread/SDL_systls.c",
        },

        .stdcpp = [_][]const u8{
            root ++ "thread/stdcpp/SDL_syscond.cpp",
            root ++ "thread/stdcpp/SDL_sysmutex.cpp",
            root ++ "thread/stdcpp/SDL_sysrwlock.cpp",
            root ++ "thread/stdcpp/SDL_systhread.cpp",
        },

        .windows = [_][]const u8{
            root ++ "thread/windows/SDL_syscond_cv.c",
            root ++ "thread/windows/SDL_sysmutex.c",
            root ++ "thread/windows/SDL_sysrwlock_srw.c",
            root ++ "thread/windows/SDL_syssem.c",
            root ++ "thread/windows/SDL_systhread.c",
            root ++ "thread/windows/SDL_systls.c",
            root ++ "thread/generic/SDL_syscond.c",
            root ++ "thread/generic/SDL_sysrwlock.c",
        },

        .generic = [_][]const u8{
            root ++ "thread/generic/SDL_syscond.c",
            root ++ "thread/generic/SDL_sysrwlock.c",
            root ++ "thread/generic/SDL_sysmutex.c",
            root ++ "thread/generic/SDL_syssem.c",
            root ++ "thread/generic/SDL_systhread.c",
            root ++ "thread/generic/SDL_systls.c",
        },

        .general = [_][]const u8{
            root ++ "thread/SDL_thread.c",
        },
    },

    .timer = .{
        .dummy = [_][]const u8{
            root ++ "timer/dummy/SDL_systimer.c",
        },

        .unix = [_][]const u8{
            root ++ "timer/unix/SDL_systimer.c",
        },

        .windows = [_][]const u8{
            root ++ "timer/windows/SDL_systimer.c",
        },

        .general = [_][]const u8{
            root ++ "timer/SDL_timer.c",
        },
    },

    .video = .{
        .macos = [_][]const u8{
            root ++ "video/cocoa/SDL_cocoaclipboard.m",
            root ++ "video/cocoa/SDL_cocoaevents.m",
            root ++ "video/cocoa/SDL_cocoakeyboard.m",
            root ++ "video/cocoa/SDL_cocoamessagebox.m",
            root ++ "video/cocoa/SDL_cocoametalview.m",
            root ++ "video/cocoa/SDL_cocoamodes.m",
            root ++ "video/cocoa/SDL_cocoamouse.m",
            root ++ "video/cocoa/SDL_cocoaopengl.m",
            root ++ "video/cocoa/SDL_cocoaopengles.m",
            root ++ "video/cocoa/SDL_cocoavideo.m",
            root ++ "video/cocoa/SDL_cocoavulkan.m",
            root ++ "video/cocoa/SDL_cocoawindow.m",
        },

        .windows = [_][]const u8{
            root ++ "video/windows/SDL_windowsclipboard.c",
            root ++ "video/windows/SDL_windowsevents.c",
            root ++ "video/windows/SDL_windowsframebuffer.c",
            root ++ "video/windows/SDL_windowskeyboard.c",
            root ++ "video/windows/SDL_windowsmessagebox.c",
            root ++ "video/windows/SDL_windowsmodes.c",
            root ++ "video/windows/SDL_windowsmouse.c",
            root ++ "video/windows/SDL_windowsopengl.c",
            root ++ "video/windows/SDL_windowsopengles.c",
            root ++ "video/windows/SDL_windowsvideo.c",
            root ++ "video/windows/SDL_windowsvulkan.c",
            root ++ "video/windows/SDL_windowswindow.c",
        },

        .linux = [_][]const u8{
            root ++ "video/x11/edid-parse.c",
            root ++ "video/x11/SDL_x11clipboard.c",
            root ++ "video/x11/SDL_x11dyn.c",
            root ++ "video/x11/SDL_x11events.c",
            root ++ "video/x11/SDL_x11framebuffer.c",
            root ++ "video/x11/SDL_x11keyboard.c",
            root ++ "video/x11/SDL_x11messagebox.c",
            root ++ "video/x11/SDL_x11modes.c",
            root ++ "video/x11/SDL_x11mouse.c",
            root ++ "video/x11/SDL_x11opengl.c",
            root ++ "video/x11/SDL_x11opengles.c",
            root ++ "video/x11/SDL_x11pen.c",
            root ++ "video/x11/SDL_x11touch.c",
            root ++ "video/x11/SDL_x11video.c",
            root ++ "video/x11/SDL_x11vulkan.c",
            root ++ "video/x11/SDL_x11window.c",
            root ++ "video/x11/SDL_x11xfixes.c",
            root ++ "video/x11/SDL_x11xinput2.c",
            root ++ "video/wayland/SDL_waylandclipboard.c",
            root ++ "video/wayland/SDL_waylanddatamanager.c",
            root ++ "video/wayland/SDL_waylanddyn.c",
            root ++ "video/wayland/SDL_waylandevents.c",
            root ++ "video/wayland/SDL_waylandkeyboard.c",
            root ++ "video/wayland/SDL_waylandmessagebox.c",
            root ++ "video/wayland/SDL_waylandmouse.c",
            root ++ "video/wayland/SDL_waylandopengles.c",
            root ++ "video/wayland/SDL_waylandvideo.c",
            root ++ "video/wayland/SDL_waylandvulkan.c",
            root ++ "video/wayland/SDL_waylandwindow.c",
        },

        .general = [_][]const u8{
            root ++ "video/SDL_blit.c",
            root ++ "video/SDL_blit_0.c",
            root ++ "video/SDL_blit_1.c",
            root ++ "video/SDL_blit_A.c",
            root ++ "video/SDL_blit_auto.c",
            root ++ "video/SDL_blit_copy.c",
            root ++ "video/SDL_blit_N.c",
            root ++ "video/SDL_blit_slow.c",
            root ++ "video/SDL_bmp.c",
            root ++ "video/SDL_clipboard.c",
            root ++ "video/SDL_egl.c",
            root ++ "video/SDL_fillrect.c",
            root ++ "video/SDL_pixels.c",
            root ++ "video/SDL_rect.c",
            root ++ "video/SDL_RLEaccel.c",
            root ++ "video/SDL_stretch.c",
            root ++ "video/SDL_surface.c",
            root ++ "video/SDL_video.c",
            root ++ "video/SDL_video_capture.c",
            root ++ "video/SDL_video_capture_apple.m",
            root ++ "video/SDL_video_capture_v4l2.c",
            root ++ "video/SDL_video_unsupported.c",
            root ++ "video/SDL_vulkan_utils.c",
            root ++ "video/SDL_yuv.c",
            root ++ "video/yuv2rgb/yuv_rgb.c",
            root ++ "video/dummy/SDL_nullevents.c",
            root ++ "video/dummy/SDL_nullframebuffer.c",
            root ++ "video/dummy/SDL_nullvideo.c",
        },
    },

    .root = [_][]const u8{
        root ++ "SDL.c",
        root ++ "SDL_assert.c",
        root ++ "SDL_error.c",
        root ++ "SDL_guid.c",
        root ++ "SDL_hashtable.c",
        root ++ "SDL_hints.c",
        root ++ "SDL_list.c",
        root ++ "SDL_log.c",
        root ++ "SDL_properties.c",
        root ++ "SDL_utils.c",
    },
};
