//
//  RecentTransactionsView.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

import SwiftUI

struct RecentTransactionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近记录")
                .font(.headline)
                .padding(.top, 8)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(height: 120)
                .overlay {
                    Text("暂无近期明细")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
        }
    }
}

final class RecentTransactionsViewModel {

}
