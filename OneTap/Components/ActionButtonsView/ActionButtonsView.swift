//
//  ActionButtonsView.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

import SwiftUI

struct ActionButtonsView: View{
    @State private var viewModel = ActionButtonsViewModel()
    var body: some View {
        // MARK: - 快捷操作按钮
            HStack(spacing: 14) {
                ActionButton(
                    title: "记支出",
                    systemImage: "arrow.up.right.circle.fill",
                    tintColor: .orange
                ) {
                    viewModel.recordTransaction(type: .expense)
                }
                
                ActionButton(
                    title: "记收入",
                    systemImage: "arrow.down.left.circle.fill",
                    tintColor: .green
                ) {
                    viewModel.recordTransaction(type: .income)
                }
            }
    }
    
    // MARK: - 自适应快捷按钮组件
    struct ActionButton: View {
        let title: String
        let systemImage: String
        let tintColor: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.title3)
                    Text(title)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(.white)
                .background(tintColor.gradient) // 渐变质感
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: tintColor.opacity(0.28), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
        }
    }
}
