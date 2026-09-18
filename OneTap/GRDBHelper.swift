//
//  GRDBHelper.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/15.
//

import Foundation
import GRDB

private class GRDBHelper {
    
    let db: DatabaseQueue?
    
    init() {
        self.db = try? DatabaseQueue(path:"/path/to/database.sqlite")
        
        try? db?.write { db in
            try db.create(table: "transaction", ifNotExists: true) { t in
                t.primaryKey ("id", .text)
                t.column("name", .text).notNull()
                t.column("score", .integer).notNull()
            }
        }
    }
    
    struct Player: Codable, Identifiable, FetchableRecord, PersistableRecord {
        var id: String
        var name: String
        var score: Int
        
        enum Columns {
            static let name = Column(CodingKeys.name)
            static let score = Column(CodingKeys.score)
        }
    }
    
    private func addData() throws {
        try db?.write { db in
            try Player(id: "1", name: "Arthur", score: 100).insert(db)
            try Player(id: "2", name: "Barbara", score: 1000).insert(db)
        }
    }
    
    private func readData() throws -> Player? {
        
        var player: Player?
        
        try db?.read { db in
            player = try Player.find(db, id: "1")
            
            
            let bestPlayers = try Player
                .order(\.score.desc)
                .limit(10)
                .fetchAll(db)
        }
        return player
    }
}
