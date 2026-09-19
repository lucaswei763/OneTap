//
//  DatabaseManager.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

import Foundation
import GRDB

struct CategoryRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "category"

    var id: String
    var name: String
    var icon: String
    var colorHex: String
    var type: String  // expense/income
    var sortOrder: Int = 0
    var isArchived: Bool = false
}

/// 某个时间区间内的收入与支出汇总（金额均存正数，方向由 type 区分）
struct MonthlyTotals: Equatable, Sendable {
    var income: Decimal = 0
    var expense: Decimal = 0
}

final class DatabaseManager {
    let dbWriter: any DatabaseWriter

    init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_create_schema") { db in
            try db.create(table: "category") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("icon", .text).notNull()
                t.column("colorHex", .text).notNull()
                t.column("type", .text).notNull()
                t.column("sortOrder", .integer).notNull().defaults(to: 0)
                t.column("isArchived", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: "transaction") { t in
                t.column("id", .text).primaryKey()
                t.column("amount", .numeric).notNull()
                t.column("type", .text).notNull()
                t.column("categoryId", .text).notNull().references("category", onDelete: .restrict)
                t.column("date", .datetime).notNull()
                t.column("note", .text)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }

            try db.create(
                index: "index_transaction_on_date_and_type",
                on: "transaction",
                columns: ["date", "type"]
            )

            try Self.seedDefaultCategories(db)
        }
        return migrator
    }

    nonisolated private static func seedDefaultCategories(_ db: Database) throws {
        let defaults: [CategoryRecord] = [
            CategoryRecord(id: "c_food", name: "餐饮", icon: "fork.knife", colorHex: "#FF9500", type: "expense", sortOrder: 1),
            CategoryRecord(id: "c_traffic", name: "交通", icon: "car.fill", colorHex: "#007AFF", type: "expense", sortOrder: 2),
            CategoryRecord(id: "c_shop", name: "购物", icon: "cart.fill", colorHex: "#AF52DE", type: "expense", sortOrder: 3),
            CategoryRecord(id: "c_salary", name: "工资", icon: "banknote.fill", colorHex: "#34C759", type: "income", sortOrder: 1),
            CategoryRecord(id: "c_bonus", name: "兼职/奖金", icon: "chart.line.uptrend.xyaxis", colorHex: "#5856D6", type: "income", sortOrder: 2),
        ]

        for category in defaults {
            try category.insert(db, onConflict: .ignore)
        }
    }
}

extension DatabaseManager {
    static let shared = makeShared()

    private static func makeShared() -> DatabaseManager {
        do {
            let fileManager = FileManager.default

            let folderURL =
                try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)

            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

            let dbURL = folderURL.appendingPathComponent("onetap.sqlite")

            let dbQueue = try DatabaseQueue(path: dbURL.path)

            return try DatabaseManager(dbQueue)
        } catch {
            fatalError("无法初始化本地数据库: \(error)")
        }
    }
}

extension DatabaseManager {
    /// 记一笔账（异步写入数据库）
    func addTransaction(
        amount: Decimal,
        type: String,
        categoryId: String,
        date: Date = Date(),
        note: String? = nil
    ) async throws {
        // 1. 构建记录对象
        var record = TransactionRecord(
            amount: amount,
            type: type,
            categoryId: categoryId,
            date: date,
            note: note
        )

        // 2. 写入数据库（GRDB 会在数据库工作线程执行写入）
        try await dbWriter.write { db in
            try record.insert(db)
        }
    }

    /// 汇总时间区间内的收入与支出
    nonisolated static func fetchTotals(in db: Database, dateInterval: DateInterval) throws -> MonthlyTotals {
        let records =
            try TransactionRecord
            .filter(Column("date") >= dateInterval.start)
            .filter(Column("date") < dateInterval.end)
            .fetchAll(db)

        var totals = MonthlyTotals()
        for record in records {
            switch record.type {
            case "income":
                totals.income += record.amount
            case "expense":
                totals.expense += record.amount
            default:
                break
            }
        }
        return totals
    }

    /// 在数据库上下文中查询分类（供非主线程的读写闭包复用）
    nonisolated static func fetchCategories(in db: Database, type: String) throws -> [CategoryRecord] {
        try CategoryRecord
            .filter(Column("type") == type)
            .filter(Column("isArchived") == false)
            .order(Column("sortOrder"))
            .fetchAll(db)
    }
}
