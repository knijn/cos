local ls = {}
ls.metadata = {
    name = "cos_ls",
    description = "An ls replacement",
    license = "MIT",
    dependencies = {}
}

ls.startup = function()
    shell.setPath("/cos/programs/cos_ls:" .. shell.path())
end

ls.update = function()
    return true
end

ls.cleanup = function ()
    return true
end

return ls