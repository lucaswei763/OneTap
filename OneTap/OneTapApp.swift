//
//  OneTapApp.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/15.
//

import GRDB
import SwiftUI

@main
struct OneTapApp: App {
    let database = DatabaseManager.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.database, database.dbWriter)
        }
    }
}

private struct DatabaseKey: EnvironmentKey {
    static let defaultValue: any DatabaseReader = DatabaseManager.shared.dbWriter
}

extension EnvironmentValues {
    var database: any DatabaseReader {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
}
