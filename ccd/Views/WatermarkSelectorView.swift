//
//  WatermarkSelectorView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

struct WatermarkSelectorView: View {
    @Binding var selectedWatermark: WatermarkType
    @Binding var isPresented: Bool
    let onCustomTextTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 拖动手柄
            Capsule()
                .fill(Color(white: 0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            // 标题
            HStack {
                Text("水印选择")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(white: 0.5))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // 水印列表
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(WatermarkType.allCases, id: \.self) { watermark in
                        WatermarkItem(
                            watermark: watermark,
                            isSelected: selectedWatermark == watermark,
                            action: {
                                if watermark == .customText {
                                    // 自定义文字需要特殊处理
                                    selectedWatermark = watermark
                                    onCustomTextTap()
                                } else {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedWatermark = watermark
                                    }
                                    
                                    // 震动反馈
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    // 自动关闭
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.spring()) {
                                            isPresented = false
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                .ignoresSafeArea()
        )
        .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
    }
}

// MARK: - 水印项目
struct WatermarkItem: View {
    let watermark: WatermarkType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // 水印图标
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.yellow : Color(white: 0.3))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: getWatermarkIcon(for: watermark))
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .black : .white)
                }
                
                // 水印信息
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(watermark.displayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isSelected ? .white : Color(white: 0.8))
                        
                        Spacer()
                        
                        if watermark.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                Text("PRO")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                    
                    // 水印预览
                    Text(watermark.getText())
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 选中指示器
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(white: 0.15) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func getWatermarkIcon(for watermark: WatermarkType) -> String {
        switch watermark {
        case .none:
            return "slash.circle"
        case .timestamp:
            return "clock"
        case .ccdBrand:
            return "camera.badge.ellipsis"
        case .vintage:
            return "star.circle"
        case .filmDate:
            return "calendar"
        case .customText:
            return "textformat.abc"
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WatermarkSelectorView(
            selectedWatermark: .constant(.timestamp),
            isPresented: .constant(true),
            onCustomTextTap: {}
        )
    }
} 