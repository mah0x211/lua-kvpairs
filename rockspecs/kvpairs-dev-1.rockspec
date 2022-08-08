package = "kvpairs"
version = "dev-1"
source = {
    url = "git+https://github.com/mah0x211/lua-kvpairs.git",
}
description = {
    summary = "helper module for treating tables as Key-Value pairs.",
    homepage = "https://github.com/mah0x211/lua-kvpairs",
    license = "MIT/X11",
    maintainer = "Masatoshi Fukunaga",
}
dependencies = {
    "lua >= 5.1",
    "metamodule >= 0.4",
}
build = {
    type = "builtin",
    modules = {
        ["kvpairs"] = "kvpairs.lua",
    },
}
