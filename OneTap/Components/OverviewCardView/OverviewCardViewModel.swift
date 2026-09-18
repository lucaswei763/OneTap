//
//  OverviewCardViewMode.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//


import Foundation

final class OverviewCardViewModel {

    var monthlyRemaining: Decimal
    var monthlyIncome: Decimal
    var monthlyExpense: Decimal
    
    init(monthlyIncome: Decimal? = 0, monthlyExpense: Decimal? = 0) {
        self.monthlyIncome = monthlyIncome ?? 0
        self.monthlyExpense = monthlyExpense ?? 0
        self.monthlyRemaining = self.monthlyIncome + self.monthlyExpense
    }
}
