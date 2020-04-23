package("lief")

    set_homepage("https://lief.quarkslab.com")
    set_description("Library to Instrument Executable Formats.")

    set_urls("https://github.com/lief-project/LIEF/archive/$(version).tar.gz",
             "https://github.com/lief-project/LIEF.git")
    add_versions("0.10.1", "6f30c98a559f137e08b25bcbb376c0259914b33c307b8b901e01ca952241d00a")

    add_deps("cmake")

    add_configs("elf",    { description = "Enable ELF module.", default = true, type = "boolean"})
    add_configs("pe",     { description = "Enable PE module.", default = true, type = "boolean"})
    add_configs("macho",  { description = "Enable MachO module.", default = true, type = "boolean"})

    add_configs("dex",    { description = "Enable Dex module.", default = false, type = "boolean"})
    add_configs("vdex",   { description = "Enable Vdex module.", default = false, type = "boolean"})
    add_configs("oat",    { description = "Enable Oat module.", default = false, type = "boolean"})
    add_configs("art",    { description = "Enable Art module.", default = false, type = "boolean"})

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DLIEF_PYTHON_API=OFF", "-DLIEF_DOC=OFF", "-DLIEF_TESTS=OFF", "-DLIEF_EXAMPLES=OFF", "-DLIEF_INSTALL_PYTHON=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DLIEF_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local parse_entry
        if package:config("elf") then
            parse_entry = "elf_parse"
        elseif package:config("pe") then
            parse_entry = "pe_parse"
        elseif package:config("macho") then
            parse_entry = "macho_parse"
        end
        if parse_entry then
            assert(package:has_cfuncs(parse_entry, {includes = "LIEF/LIEF.h"}))
        end
    end)
