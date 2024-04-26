return {
    silent_startup = false,
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