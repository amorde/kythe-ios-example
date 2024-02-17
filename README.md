
This is an iOS codebase built with Bazel to serve as an example for use with [Kythe](https://kythe.io/).

## Building this repo and running Kythe

### Kythe Setup

For convenience I've created a personal fork & branch that includes the objective-c bazel extractor in the list of
artifacts that Kythe builds when building the `//kythe/release` target.

```
git clone https://github.com/amorde/kythe.git
git checkout origin/release-objc-bazel-extractor
cd kythe
bazel build //kythe/release
# Extract the release tarball built above
tar xf bazel-bin/kythe/release/kythe-v0.0.65.tar.gz
# Set $KYTHE_RELEASE to the extracted folder
export KYTHE_RELEASE="$(pwd)/kythe-v0.0.65"
```

### Building the example app

First, verify you can build the app without any other changes.

```
bazel build //ios:App
```

If this does not succeed, you may have a different compilation environment. This
repo was setup with the following:

* Xcode 15.1 (15C65)
* macOS Sonoma 13.4
* Bazel 7.0.2
* Ruby 3.2.2


### Extracting Kythe compilations

Using `$KYTHE_RELEASE` from the earlier Kythe setup we can follow the pattern described
[here](https://kythe.io/examples/#extracting-other-bazel-based-repositories) we can inject the Bazel configurations into the build

```
bazel --bazelrc=$KYTHE_RELEASE/extractors.bazelrc build --override_repository kythe_release=$KYTHE_RELEASE //ios:App 
```

This will produce `.objc.kzip` files in `bazel-out`:

```
$ find -L bazel-out -name '*.kzip'

bazel-out/ios-sim_arm64-min14.0-applebin_ios-ios_sim_arm64-dbg-ST-9ef79b6d9025/extra_actions/extract_kzip_objc_extra_action/ios/3023bac10e22e4a9669246ddbc63044a21b1081ebc925f35eca889be718f7991.objc.kzip
bazel-out/ios-sim_arm64-min14.0-applebin_ios-ios_sim_arm64-dbg-ST-9ef79b6d9025/extra_actions/extract_kzip_objc_extra_action/ios/79eadbf3994af8011abfc41996fc2f74092bef7b42c5d7e8b6c4ef12be706f11.objc.kzip
bazel-out/ios-sim_arm64-min14.0-applebin_ios-ios_sim_arm64-dbg-ST-9ef79b6d9025/extra_actions/extract_kzip_objc_extra_action/ios/d78a0106d6c490cf89cc2b21cbad4df2fae3430048a7e72b4fde38bc61f2ec71.objc.kzip
bazel-out/ios-sim_arm64-min14.0-applebin_ios-ios_sim_arm64-dbg-ST-9ef79b6d9025/extra_actions/extract_kzip_objc_extra_action/ios/2f2275afa47141b0195d11790a805d4496ee1419c2a39a4127612cd04fc46992.objc.kzip
bazel-out/ios-sim_arm64-min14.0-applebin_ios-ios_sim_arm64-dbg-ST-9ef79b6d9025/extra_actions/extract_kzip_objc_extra_action/ios/7f17a328e5a94f3df55f2234fda0e3f66f3bf59244db714bb0dc6fb6fb64dcec.objc.kzip
bazel-out/ios-sim_arm64-min14.0-applebin_ios-ios_sim_arm64-dbg-ST-9ef79b6d9025/extra_actions/extract_kzip_objc_extra_action/ios/b2bb293e7e439ce53a66479abaee491168dc230986005386b0ef4a79f1c550af.objc.kzip
bazel-out/ios-sim_arm64-min14.0-applebin_ios-ios_sim_arm64-dbg-ST-ca5ec8366a76/extra_actions/extract_kzip_objc_extra_action/external/bazel_tools/tools/objc/fe1615466548789a05f381ba52ba3408eb933db014335cc8e6bdb68bae0d75fe.objc.kzip
```

There will also be several errors included in the output of the build command:

```
INFO: Invocation ID: 3a3f2b73-7f25-4627-8151-911d6e6b2106
INFO: Analyzed target //ios:App (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on @bazel_tools//tools/objc:dummy_lib:
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on //ios:ModuleA_objc:
error: unknown argument: '-index-store-path'
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
error: no such file or directory: 'bazel-out/_global_index_store'
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on //ios:ModuleB_objc:
error: unknown argument: '-index-store-path'
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
error: no such file or directory: 'bazel-out/_global_index_store'
ios/ModuleB/BObject.m:1:9: fatal error: module 'ModuleA' not found
    1 | @import ModuleA;
      |  ~~~~~~~^~~~~~~
1 error generated.
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on //ios:App_objc:
error: unknown argument: '-index-store-path'
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
error: no such file or directory: 'bazel-out/_global_index_store'
ios/App/main.m:1:9: fatal error: module 'ModuleA' not found
    1 | @import ModuleA;
      |  ~~~~~~~^~~~~~~
1 error generated.
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on //ios:ModuleA_objc:
error: unknown argument: '-index-store-path'
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
error: no such file or directory: 'bazel-out/_global_index_store'
Target //ios:App up-to-date:
  bazel-bin/ios/App.ipa
INFO: Elapsed time: 0.291s, Critical Path: 0.23s
INFO: 6 processes: 5 disk cache hit, 1 internal.
INFO: Build completed successfully, 6 total actions
```

These errors do not seem to impact the extraction:
* `error: unknown argument: '-index-store-path'`
* `error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'`
* `error: no such file or directory: 'bazel-out/_global_index_store'`

The compilation error, however, does:

```
ios/App/main.m:1:9: fatal error: module 'ModuleA' not found
    1 | @import ModuleA;
      |  ~~~~~~~^~~~~~~
1 error generated.
```

I've narrowed this down to the usage of virtual framework overlays via the `--features=apple.virtualize_frameworks` option for [rules_apple](https://github.com/bazelbuild/rules_apple).


Commenting out this line from `.bazelrc`:

```
build --features=apple.virtualize_frameworks
```

and re-running the same build command will remove the import errors:

```
# Ensure we get a clean build
bazel clean --expunge
bazel --bazelrc=$KYTHE_RELEASE/extractors.bazelrc build --override_repository kythe_release=$KYTHE_RELEASE //ios:App

Starting local Bazel server and connecting to it...
INFO: Invocation ID: c53689ba-93f3-402b-be21-487ed5e9563b
INFO: Analyzed target //ios:App (81 packages loaded, 1429 targets configured).
INFO: Found 1 target...
INFO: From Linking external/build_bazel_rules_ios/rules/hmap/hmaptool [for tool]:
ld: warning: ignoring duplicate libraries: '-lc++'
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on @bazel_tools//tools/objc:dummy_lib:
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on //ios:App_objc:
error: unknown argument: '-index-store-path'
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
error: no such file or directory: 'bazel-out/_global_index_store'
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on //ios:ModuleB_objc:
error: unknown argument: '-index-store-path'
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
error: no such file or directory: 'bazel-out/_global_index_store'
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on //ios:ModuleA_objc:
error: unknown argument: '-index-store-path'
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
error: no such file or directory: 'bazel-out/_global_index_store'
INFO: From Executing extra_action @kythe_release//:extract_kzip_objc_extra_action on //ios:ModuleA_objc:
error: unknown argument: '-index-store-path'
error: no such file or directory: 'DEBUG_PREFIX_MAP_PWD=.'
error: no such file or directory: 'bazel-out/_global_index_store'
Target //ios:App up-to-date:
  bazel-bin/ios/App.ipa
INFO: Elapsed time: 22.024s, Critical Path: 0.95s
INFO: 104 processes: 36 disk cache hit, 66 internal, 2 local.
INFO: Build completed successfully, 104 total actions
```

### Running the Kythe indexers

After building with the compilation extractors we can now run the actual indexers
to index the code. The steps for this are collected into a script.

```
# First argument is a folder name which will be the destination for the produced files
./index_from_bazel.rb kythe_database
```

This will likely encounter another set of errors:

```
... (ommitted for brevity)
/Applications/Xcode/15.1/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.2.sdk/usr/include/module.modulemap:273:11: header 'sched.h' not found
/Applications/Xcode/15.1/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.2.sdk/usr/include/module.modulemap:273:11: header 'sched.h' not found
/Applications/Xcode/15.1/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.2.sdk/usr/include/module.modulemap:273:11: header 'sched.h' not found
/Applications/Xcode/15.1/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.2.sdk/usr/include/module.modulemap:273:11: header 'sched.h' not found
/Applications/Xcode/15.1/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.2.sdk/System/Library/Frameworks/QuartzCore.framework/Headers/CABase.h:16:10: could not build module 'CoreFoundation'
/Applications/Xcode/15.1/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.2.sdk/System/Library/Frameworks/Symbols.framework/Headers/Symbols.h:8:9: could not build module 'Foundation'
/Applications/Xcode/15.1/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.2.sdk/System/Library/Frameworks/FileProvider.framework/Headers/NSFileProviderDomain.h:8:9: could not build module 'Foundation'
/Applications/Xcode/15.1/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.2.sdk/System/Library/Frameworks/UserNotifications.framework/Headers/NSString+UserNotifications.h:8:9: could not build module 'Foundation'
bazel-out/ios-sim_arm64-min14.0-applebin_ios-ios_sim_arm64-dbg-ST-9ef79b6d9025/bin/ios/ModuleA/ModuleA.framework/Headers/ModuleA-umbrella.h:2:13: could not build module 'Foundation'
```

Despite the errors some data will be collected and the kythe CLI can be used to explore it:

```
$KYTHE_RELEASE/tools/kythe --api kythe_database decor "kythe://kythe-ios-example?path=ios/App/main.m"
```

