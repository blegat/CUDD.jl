using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libcudd"], Symbol("libcudd")),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/sisl/CUDDBuilder/releases/download/v3.0.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    MacOS(:x86_64) => ("$bin_prefix/CUDDBuilder.v3.0.0.x86_64-apple-darwin14.tar.gz", "90b673803d0afc40d68306effb7c7752b5b41db6409160f4cbaf1a6d4406d45a"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/CUDDBuilder.v3.0.0.x86_64-linux-gnu.tar.gz", "9b3c177b5d66164ec8bc4bf67fc1bbeae8538bc6a911239cb301e9bbd9edb500"),
    Windows(:x86_64) => ("$bin_prefix/CUDDBuilder.v3.0.0.x86_64-w64-mingw32.tar.gz", "0729d152b32b5e0fb99dd656ea5cbc32c81d90e4ffad208c9e39a9de811119db"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)