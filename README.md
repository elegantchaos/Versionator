# Versionator

This is a little proof-of-concept plugin which gathers version information and embeds it into the package/executable, in a way that allows it to be retrieved at runtime.

This experiments with a couple of approaches:

- generating a swift file which then gets built into the package
- generating an info.plist file which gets embedded as a package resource

See https://github.com/elegantchaos/VersionatorTest for an example command line tool which uses the plugin.

## Swift API

The generated Swift API defines a `CurrentVersion` struct, with some static properties:

- `build`: the build number
- `commit`: the current git commit
- `git`: a git-style `describe` string such as "v1.0.1-23-ae34dec"

The build number is derived from the git commit count on the current branch. This is a fairly standard technique but other approaches could obviously be taken.

The git-style string is derived from the latest version tag on the current branch. 

Currently I'm just returning it verbatim, but the plugin could be extended to parse this more fully. It could then returns the semantic version as a struct split into components.


## Info.plist

As an experiment, this plugin also generates an Info.plist, which gets bundled into the package resources.

This can then be accessed with `Bundle.module`.

I was hoping that `Bundle.module.infoDictionary` would be populated with the content of the Info.plist file, but apparently not.

However, you can fish out the URL and load it yourself easily enough.

This seems to produce a cyclic-dependency warning in Xcode, due to the fact that the client executable uses the bundle, and the bundle contains the Info.plist, but the Info.plist is built during the build of the client executable.

This might be fixed by making this a prebuild plugin, which is what I initially tried to do.

Unfortunately prebuild plugins seem to have a limitation in that the tool they run can only be a binaryTarget - ie a precompiled binary that's been commited/uploaded elsewhere. That's a bit of a rubbish limitation right now for such a simple plugin, and it really cramps one's style whilst developing the plugin, so I switched to using a build plugin instead. Hopefully this limitation will be fixed.   

## Info.plist Thoughts

My current Xcode workflow for app development involves pulling in some standard tools as an SPM package, and building/running them in a build phase, in order to make a Info.h file with C-style constant definitions in it, which I then set as the INFOPLIST_PREFIX_HEADER in Xcode.
 
This works ok, but having to set up the build phase, and have it bootstrap building the tool, is all a bit clunky.

It would be great if I could replace it with an approach based on SPM plugins instead.

I like the idea of injecting values into the Info.plist, but I expect you'd want that to be a separate tool, since you'd need to take the majority of the Info.plist content from elsewhere.

What I'm thinking of there is possibly having an Info-builder tool, which takes its input from multiple source files (eg "Blah.info"). These could be in JSON or Plist format, and be merged together to form the final Info.plist.

This version number plugin could then generate one of those `.info` files, with the version items in it; which would get merged in alongside everything else.
 
