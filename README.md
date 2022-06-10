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


# Info.plist Thoughts

My current Xcode workflow for app development involves pulling in some standard tools as an SPM package, and building/running them in a build phase, in order to make a Info.h file with C-style constant definitions in it, which I then set as the INFOPLIST_PREFIX_HEADER in Xcode.
 
This works ok, but having to set up the build phase, and have it bootstrap building the tool, is all a bit clunky.

It would be great if I could replace it with an approach based on SPM plugins instead.

I like the idea of injecting values into the Info.plist, but I expect you'd want that to be a separate tool, since you'd need to take the majority of the Info.plist content from elsewhere.

What I'm thinking of there is possibly having an Info-builder tool, which takes its input from multiple source files (eg "Blah.info"). These could be in JSON or Plist format, and be merged together to form the final Info.plist.

This version number plugin could then generate one of those `.info` files, with the version items in it; which would get merged in alongside everything else.
 
