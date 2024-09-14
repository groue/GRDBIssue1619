import GRDB
import SwiftUI

@main
struct Issue1619App: App {
    let sqliteVersion: String = {
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
