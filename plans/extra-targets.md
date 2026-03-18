
# Add handling of Extra Targets in PSProjectConfigWasm

```toml

[tool.psproject.swift_packages]
# name = { url = } doesnt have to be the same as the name in the dependencies list, 
# but it can be if you want it to be. The name is just a reference for the dependency, and the url is where to find it.
# options for when url = "" are:
# - upToNextMajor = "1.2.3"
# - upToNextMinor = "1.2.3"
# - version = "1.2.3"
# - branch = "branch_name"
# - revision = "commit_hash"
# else for path just path = "../path/to/dependency"
OneSignal = { url = "https://github.com/OneSignal/OneSignal-XCFramework", upToNextMajor = "5.4.1" }


# PSProject configuration for createing extra targets, such as app extensions.
# and specified as [tool.psproject.extra_targets.<target_name>] where <target_name> is the name of the target you want to create.
[tool.psproject.extra_targets.UpdatesTestNotificationExtension]
name = "UpdatesTestNotificationExtension"
type = "app_extension"
sources = ["swift_files/UpdatesTestNotificationExtension.swift"]
backends = []
dependencies = [
    { package = { products = ["OneSignalExtension"], reference = "OneSignal" } }
]


[tool.psproject.extra_targets.UpdatesTestNotificationExtension.entitlements]
"com.apple.security.application-groups" = ["group.org.pyswift.updatestest.onesignal"]


[tool.psproject.extra_targets.UpdatesTestNotificationExtension.info_plist.NSExtension]
NSExtensionPointIdentifier = "com.apple.usernotifications.service"
NSExtensionPrincipalClass = "UpdatesTestNotificationExtension"

```

it requires Swift Packages are being handled now also.

