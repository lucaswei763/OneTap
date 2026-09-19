//
//  TransactionRecord.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

import Foundation
import GRDB

struct TransactionRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "transaction"

    var id: String
    var amount: Decimal
    var type: String  // "expense" 或 "income"
    var categoryId: String  // 对应分类的 ID
    var date: Date  // 消费/收入发生时间
    var note: String?  // 备注（可选）
    var createdAt: Date  // 记录创建时间
    var updatedAt: Date  // 记录修改时间

    // 构造方法：赋予常用默认值（如自动生成 UUID 和当前时间）
    init(
        id: String = UUID().uuidString,
        amount: Decimal,
        type: String,
        categoryId: String,
        date: Date = Date(),
        note: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.date = date
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
