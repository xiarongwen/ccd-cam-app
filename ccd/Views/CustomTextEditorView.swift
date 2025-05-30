//
//  CustomTextEditorView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

struct CustomTextEditorView: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("自定义水印文字")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // 文本输入框
            VStack(alignment: .leading, spacing: 10) {
                Text("输入您的水印文字:")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                TextField("请输入文字...", text: $text)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(white: 0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(white: 0.3), lineWidth: 1)
                            )
                    )
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        saveAndClose()
                    }
                
                // 字符计数
                HStack {
                    Spacer()
                    Text("\(text.count)/20")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // 预设文字选项
            VStack(alignment: .leading, spacing: 12) {
                Text("或选择预设文字:")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(presetTexts, id: \.self) { preset in
                        PresetTextButton(
                            text: preset,
                            isSelected: text == preset
                        ) {
                            text = preset
                        }
                    }
                }
            }
            
            // 操作按钮
            HStack(spacing: 20) {
                Button("取消") {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(white: 0.2))
                )
                
                Button("确定") {
                    saveAndClose()
                }
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.yellow)
                )
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(white: 0.2), lineWidth: 1)
                )
        )
        .onAppear {
            // 自动聚焦到文本框
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
        .onChange(of: text) { newValue in
            // 限制字符数
            if newValue.count > 20 {
                text = String(newValue.prefix(20))
            }
        }
    }
    
    private var presetTexts: [String] {
        [
            "FILM",
            "VINTAGE",
            "RETRO",
            "90s",
            "ANALOG",
            "MEMORY",
            "MOMENT",
            "CLASSIC"
        ]
    }
    
    private func saveAndClose() {
        // 震动反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring()) {
            isPresented = false
        }
    }
}

// MARK: - 预设文字按钮
struct PresetTextButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.yellow : Color(white: 0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.yellow : Color(white: 0.3), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CustomTextEditorView(
            text: .constant(""),
            isPresented: .constant(true)
        )
    }
} 