return {
    silent_startup = false,
    settings = {
        ["path.programs"] = "/cos/programs/ccsmb10"
    },
    packages = {
        cos_syslog = {
            path = ".syslog",
            daemon = true
        },
        cos_daemon = {},
        installer = {},
    }
}