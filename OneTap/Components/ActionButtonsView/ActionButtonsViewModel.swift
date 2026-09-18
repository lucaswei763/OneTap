//
//  ActionButtonsViewModel.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

enum TransactionType {
    case income   // 收入
    case expense  // 支出
}

final class ActionButtonsViewModel {
    func recordTransaction(
//        amount: Decimal,
        type: TransactionType,
//        category: String,
//        date: Date = Date(),
//        note: String? = nil
    ) {
        print("recordTrasaction: \(type)")
    }
}
