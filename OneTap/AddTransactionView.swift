//
//  AddTransactionView.swift
//  OneTap
//
//  Created by 韦亦航 on 2026/9/19.
//

import AlertToast
import SwiftUI
import GRDB

struct AddTransactionView: View {
    /// 记账类型由入口按钮决定，表单内不可切换
    let type: TransactionType
    /// 记账成功后的回调（在关闭表单前触发）
    var onSaved: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @Environment(\.database) private var database

    @State private var amountString = ""
    @State private var note = ""
    @State private var categories: [CategoryRecord] = []
    @State private var selectedCategoryId: String?
    @State private var isLoadingCategories = true
    @State private var isSaving = false
    @State private var isShowingErrorToast = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("金额") {
                    TextField("0.00", text: $amountString)
                        .keyboardType(.decimalPad)
                }

                Section("分类") {
                    categoryContent
                }

                Section("备注") {
                    TextField("选填", text: $note, axis: .vertical)
                        .lineLimit(1...3)
                }
            }
            .navigationTitle(type.formTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task { await save() }
                    }
                    .disabled(isSaving || isLoadingCategories || categories.isEmpty)
                }
            }
            .task {
                await loadCategories()
            }
            .toast(isPresenting: $isShowingErrorToast, duration: 2, tapToDismiss: true) {
                AlertToast(type: .error(.red), title: errorMessage)
            }
        }
    }

    // MARK: - 分类

    @ViewBuilder
    private var categoryContent: some View {
        if isLoadingCategories {
            HStack(spacing: 8) {
                ProgressView()
                Text("正在加载分类…")
                    .foregroundStyle(.secondary)
            }
        } else if categories.isEmpty {
            Text("暂无可用分类")
                .foregroundStyle(.secondary)
        } else {
            Picker("分类", selection: $selectedCategoryId) {
                ForEach(categories, id: \.id) { category in
                    Label(category.name, systemImage: category.icon)
                        .tag(category.id as String?)
                }
            }
        }
    }

    // MARK: - 数据

    private func loadCategories() async {
        isLoadingCategories = true
        defer { isLoadingCategories = false }

        let categoryType = type.databaseValue

        do {
            let fetched = try await database.read { db in
                try DatabaseManager.fetchCategories(in: db, type: categoryType)
            }
            categories = fetched
            selectedCategoryId = fetched.first?.id
        } catch {
            categories = []
            selectedCategoryId = nil
            showError("分类加载失败：\(error.localizedDescription)")
        }
    }

    private func save() async {
        guard !isSaving else { return }

        guard let amount = Decimal(string: amountString.trimmingCharacters(in: .whitespaces)), amount > 0 else {
            showError("请输入大于 0 的金额")
            return
        }

        guard let categoryId = selectedCategoryId else {
            showError("请先选择分类")
            return
        }

        isSaving = true
        defer { isSaving = false }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try await DatabaseManager.shared.addTransaction(
                amount: amount,
                type: type.databaseValue,
                categoryId: categoryId,
                date: Date(),
                note: trimmedNote.isEmpty ? nil : trimmedNote
            )
            onSaved()
            dismiss()  // 关闭当前页面返回首页
        } catch {
            showError("记账失败：\(error.localizedDescription)")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        isShowingErrorToast = true
    }
}
