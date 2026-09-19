//
//  OverviewCardViewMode.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

internal import Combine
import Foundation
import GRDB

final class OverviewCardViewModel: ObservableObject {

    @Published private(set) var monthlyIncome: Decimal = 0
    @Published private(set) var monthlyExpense: Decimal = 0

    private var observationCancellable: AnyDatabaseCancellable?

    var monthlyRemaining: Decimal {
        monthlyIncome - monthlyExpense
    }

    /// 开始观察本月收支，数据库变化后自动刷新；重复调用会先取消上一次观察
    func startObservingMonthlyTotals(in reader: any DatabaseReader) {
        stopObservingMonthlyTotals()

        let observation = ValueObservation.tracking { db in
            try DatabaseManager.fetchTotals(
                in: db,
                dateInterval: OverviewCardViewModel.currentMonthInterval()
            )
        }

        observationCancellable = observation.start(
            in: reader,
            onError: { error in
                print("本月收支观察失败: \(error)")
            },
            onChange: { [weak self] totals in
                self?.monthlyIncome = totals.income
                self?.monthlyExpense = totals.expense
            }
        )
    }

    func stopObservingMonthlyTotals() {
        observationCancellable?.cancel()
        observationCancellable = nil
    }

    /// 当前自然月区间：[本月 1 日 00:00, 次月 1 日 00:00)
    nonisolated static func currentMonthInterval(
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> DateInterval {
        calendar.dateInterval(of: .month, for: now) ?? DateInterval(start: now, duration: 0)
    }
}
