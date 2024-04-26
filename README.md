# cOS, the configurable OS

NOTE! cOS isn't done and this is currently in a beta phase.

cOS is a configurable OS inspired by NixOS built for ComputerCraft. The entire configuration of the OS is built from a single configuration file, which enables and disables specific elements of the OS. 
Any package that isn't configured won't be enabled (unless another package relies on it) and thus won't be usable.
As the packages system is completely modular, anything can be done on startup. The intended way to use the packages system is to use a package as an installer for a package, not as the actual code of the package itself. 
This practice is ignored by the system utilities in order to bundle system utilities with the OS itself.

## Features
- Package installation from /cos/config.lua
- .settings file definition from /cos/config.lua
- Easy simple background runners using redrun
- Easily expandable

### Complaince
We comply with the following standards
- CCSMB-10

## Installation
Run the following command to install the latest build
```
wget run https://raw.githubusercontent.com/knijn/cos/main/cos/programs/installer/installer.lua install
```

## Example configuration
Here's the example /cos/config.lua file
```lua
return {
    silent_startup = false,
    packages = {
        cos_syslog = {
            path = "/.syslog",
            daemon = true
        },
        cos_daemon = {}
    }
}
```

## File structure
```
.
├── cos
│   ├── config.lua (the main configuration file)
│   ├── hook.lua (the file that gets ran on startup)
│   ├── lib (libraries are stored here)   
│   ├── packages (the package definition files itself)
│   │   ├── cos_daemon.lua
│   │   ├── redrun.lua
│   │   ├── syslog.lua
│   │   └── ...
│   └── programs (folder which holds the programs that a package installs)
│       ├── syslog (a package puts this folder into the path to enable itself
|       |   └── syslog.lua
│       └── ... 
└── startup.lua (program that runs hook.lua that does all the magic)
```

## List of packages and their respective configuration options
```lua
return {
    silent_startup = false,
    pretty_boot = true, -- wether to show the pretty boot screen during bootup
    pretty_boot_time = 2, -- an amount of time to add to wait until continuing. this is to make the actual screen visible
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
            path = ".syslog",
            daemon = true
        },
        cos_daemon = {},
        cos_ls = {} -- Currently broken when running `ls`
        installer = { -- this is the installer configuration used to build cos
            directories = {
                "/cos/programs/",
                "/cos/packages/"
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
```

## Environment
cOS makes the following information available in the environment:
```lua
_G.cos_loaded_packages -- A table of packages and wether they're loaded or not
-- example:
_G.cos_loaded_packages.syslog = "true" -- true if it loaded correctly, false if it didnt


_G.cos_packages -- A table that a package can insert data into

_G.cos_packages_config -- A table where each package gets their config inserted into
-- example:
_G.cos_packages_config.syslog = {
            path = ".syslog",
            daemon = true
        },
```

## Roadmap
The following things are planned, but not implemented yet:
- firstrun hook for packages
- CCSMB-9 compliance, whenever passed
