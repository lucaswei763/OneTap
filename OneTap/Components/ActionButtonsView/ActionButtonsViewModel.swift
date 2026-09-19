//
//  ActionButtonsViewModel.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

internal import Combine
import Foundation

enum TransactionType: String, Sendable {
    case income  // 收入
    case expense  // 支出

    /// 写入数据库时使用的类型值
    nonisolated var databaseValue: String {
        rawValue
    }

    /// 记账表单标题
    nonisolated var formTitle: String {
        switch self {
        case .income: "记收入"
        case .expense: "记支出"
        }
    }
}

final class ActionButtonsViewModel: ObservableObject {

    /// 是否正在展示记账表单
    @Published var isPresentingAddTransaction = false

    /// 待记账的类型，由点击的按钮决定
    @Published private(set) var pendingType: TransactionType = .expense

    /// 点击「记支出／记收入」：确定类型并弹出记账表单
    func recordTransaction(type: TransactionType) {
        pendingType = type
        isPresentingAddTransaction = true
    }
}
