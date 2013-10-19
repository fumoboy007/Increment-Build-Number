Increment Build Number
======================
    Increments an Xcode project's build number.
    
    Usage: increment-build-number [options] info_plist_path...
    
    Options:
        { -f | --format } build_number_format
            Specifies the format that the build number should be in. Valid values:
            basic (e.g. 253), Apple (e.g. 3A201)
        { -m | --restartOnMajor }
            Restart numbering after a new major version (only applicable to
            Apple-style build numbers).
        { -h | --help }
            Show this help message.

License
-------
Licensed under the MIT license.