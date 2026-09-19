//
//  HomeView.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    OverviewCardView()  // 1. 概览/资产卡片
                    ActionButtonsView()  // 2. 核心操作按钮组（支出 / 收入）
                    RecentTransactionsView()  // 3. 近期明细区域
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("财务概览")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("add account")
                    } label: {
                        Image(systemName: "plus.app")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
