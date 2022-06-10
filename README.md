# Versionator

This is a little proof-of-concept plugin which gathers version information and embeds it into the package/executable, in a way that allows it to be retrieved at runtime.

This experiments with a couple of approaches:

- generating a swift file which then gets built into the package
- generating an info.plist file which gets embedded as a package resource


## Swift API

The generated Swift API defines a `CurrentVersion` struct, with some static properties:

- `build`: the build number
- `commit`: the current git commit
- `git`: a git-style `describe` string such as "v1.0.1-23-ae34dec"

The git-style string is derived from the latest version tag on the current branch. 

The pluging could be extended to parse this more fully, and add a `version` property which returns the semantic version as a struct. 


## Info.plist

As an experiment, this plugin also generates an Info.plist, which gets bundled into the package resources.

This can then be accessed with `Bundle.module`.

I was hoping that `Bundle.module.infoDictionary` would be populated with the content of the Info.plist file, but apparently not.

However, you can fish out the URL and load it yourself easily enough.

