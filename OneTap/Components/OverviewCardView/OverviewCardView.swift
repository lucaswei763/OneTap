//
//  OverviewCardView.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

import SwiftUI

// MARK: - 资产概览卡片
struct OverviewCardView: View {
    @State private var viewModel = OverviewCardViewModel(monthlyIncome: 1000, monthlyExpense: -1500)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("本月结余")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("\(viewModel.monthlyRemaining, format: .currency(code: "CNY"))")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            HStack {
                summaryItem(title: "本月支出", amount: viewModel.monthlyExpense, color: .orange)
                Spacer()
                summaryItem(title: "本月收入", amount: viewModel.monthlyIncome, color: .green)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private func summaryItem(title: String, amount: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(amount, format: .currency(code: "CNY"))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
    }
}
