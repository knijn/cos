# cOS, the configurable OS

NOTE! cOS isn't done and this is currently in a proof of concept phase.

cOS is a configurable OS inspired by NixOS built for ComputerCraft. The entire configuration of the OS is built from a single configuration file, which enables and disables specific elements of the OS. 
Any package that isn't configured won't be enabled (unless another package relies on it) and thus won't be usable.

Here's an example /cos/config.lua file
```lua
return {
    silent_startup = false,
    packages = {
        syslog = {
            path = ".syslog",
            daemon = true
        },
        cos_daemon = {}
    }
}
```

As the packages system is completely modular, anything can be done on startup. The intended way to use the packages system is to use a package as an installer for a package, not as the actual code of the package itself. 
This practice is ignored by the system utilities in order to bundle system utilities with the OS itself.
Here's the folder structure:
```
.
├── cos
│   ├── config.lua (the main configuration file)
│   ├── hook.lua (the file that gets ran on startup)
│   ├── packages (the package definition files itself)
│   │   ├── cos_daemon.lua
│   │   ├── redrun.lua
│   │   └── syslog.lua
│   └── programs (folder which holds the programs that a package installs)
│       └── syslog (a package puts this folder into the path to enable itself)
│           └── syslog.lua
└── startup.lua (program that runs hook.lua)
```