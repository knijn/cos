return {
    silent_startup = false,
    pretty_boot = true,
    pretty_boot_time = 1,
    theme = {
        primary_color = colors.blue,
        secondary_color = colors.lightBlue,
        text_color = colors.white
    },
    settings = {
        ["path.programs"] = "/cos/programs/ccsmb10"
    },
    packages = {
        cos_syslog = {
            path = "/.syslog",
            daemon = true
        },
        cos_daemon = {},
        installer = {
            directories = {
                "/cos/programs",
                "/cos/packages"
            },
            files = {
                "/cos/hook.lua",
                "/startup.lua"
            },
            ignore = {
                "/cos/programs/ccsmb10"
            }
        },
    }
}