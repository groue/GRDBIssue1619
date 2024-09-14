# GRDB Issue 1619

This repository reproduces the crash described at [groue/GRDB.swift#1619](https://github.com/groue/GRDB.swift/issues/1619).

What I did:

1. Create a new iOS app project from Xcode 16 RC. - [2ebd9547](https://github.com/groue/GRDBIssue1619/commit/2ebd9547aab381d5ddac6d359864717e563c0009)

    ✅ The app builds and run.

2. Add a dependency on GRDB 6.29.3, set IPHONEOS_DEPLOYMENT_TARGET to 17.6, and use GRDB through an existential. - [4d5df41c](https://github.com/groue/GRDBIssue1619/commit/4d5df41c0b3d686775f6c2993edc35f33b96f162))

    ✅ The app builds and run.

    ```swift
    import GRDB
    import SwiftUI

    @main
    struct Issue1619App: App {
        let sqliteVersion: String = {
            // The existential
            let writer: any DatabaseWriter = try! DatabaseQueue()
            return try! writer.read { db in
                try String.fetchOne(db, sql: "SELECT sqlite_version()")!
            }
        }()
    
        var body: some Scene {
            WindowGroup {
                VStack {
                    Text("SQLite version: \(sqliteVersion)")
                }
            }
        }
    }
    ```

3. Set IPHONEOS_DEPLOYMENT_TARGET to 18.0 - [e21c7d84](https://github.com/groue/GRDBIssue1619/commit/e21c7d84d35fedd0accf487d274e31968f648738)

    💥 Crash

    ```swift
    let writer: any DatabaseWriter = try! DatabaseQueue()
    // Thread 1: EXC_BAD_ACCESS (code=1, address=0x28)
    return try! writer.read { db in
        try String.fetchOne(db, sql: "SELECT sqlite_version()")!
    }
    ```
    
    Stack trace
    
    ```
    Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
    0   Issue1619.debug.dylib         	       0x103b0b808 closure #1 in variable initialization expression of Issue1619App.sqliteVersion + 200 (Issue1619App.swift:8)
    1   Issue1619.debug.dylib         	       0x103b0c724 Issue1619App.init() + 32 (Issue1619App.swift:6)
    2   Issue1619.debug.dylib         	       0x103b0c7b8 protocol witness for App.init() in conformance Issue1619App + 20
    3   SwiftUI                       	       0x1d1b70c7c static App.main() + 132
    4   Issue1619.debug.dylib         	       0x103b0c68c static Issue1619App.$main() + 40
    5   Issue1619.debug.dylib         	       0x103b0c7dc __debug_main_executable_dylib_entry_point + 12 (Issue1619App.swift:5)
    6   dyld_sim                      	       0x102f8d410 start_sim + 20
    7   dyld                          	       0x1028c2154 start + 2476
    ```
    

4. Push a modified version of GRDB with iOS 18 as the minimum version, on the [dev/issue1619-iOS18](https://github.com/groue/GRDB.swift/tree/dev/issue1619-iOS18) branch, and modify the app in this repository so that it uses that version of GRDB - [2e789c2b](https://github.com/groue/GRDBIssue1619/commit/2e789c2b53440a48a24f9c6ac9db2ecc64883293)

    ✅ The app builds and run.

5. Revert the last commit so that the app crashes again and reproduces the issue. [6867d8a7](https://github.com/groue/GRDBIssue1619/commit/6867d8a7d829cd8e61e9f2433e4b6d7516d47119)

    💥 Crash

6. Add this README
