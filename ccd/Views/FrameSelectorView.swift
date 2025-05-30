//
//  FrameSelectorView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

struct FrameSelectorView: View {
    @Binding var selectedFrame: FrameType
    @Binding var isPresented: Bool
    
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
                Text("相框选择")
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
            
            // 相框网格
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(FrameType.allCases, id: \.self) { frame in
                        FrameCard(
                            frame: frame,
                            isSelected: selectedFrame == frame,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedFrame = frame
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
        .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
    }
}

// MARK: - 相框卡片
struct FrameCard: View {
    let frame: FrameType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // 相框预览
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? Color.yellow : Color(white: 0.3),
                                    lineWidth: isSelected ? 3 : 1
                                )
                        )
                        .shadow(
                            color: isSelected ? Color.yellow.opacity(0.3) : Color.black.opacity(0.5),
                            radius: isSelected ? 10 : 5,
                            x: 0,
                            y: 3
                        )
                    
                    // 相框预览图
                    FramePreview(frame: frame)
                        .frame(width: 120, height: 150)
                        .clipped()
                }
                .aspectRatio(4/5, contentMode: .fit)
                
                // 相框名称和状态
                VStack(spacing: 4) {
                    Text(frame.displayName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(isSelected ? .white : Color(white: 0.8))
                        .lineLimit(1)
                    
                    if frame.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text("PRO")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.yellow)
                    }
                }
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - 相框预览
struct FramePreview: View {
    let frame: FrameType
    
    var body: some View {
        let params = frame.frameParams
        
        ZStack {
            // 相框外形
            RoundedRectangle(cornerRadius: params.cornerRadius)
                .fill(params.color)
            
            // 内部照片区域
            VStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    )
                    .padding(.top, params.topPadding / 3)
                    .padding(.horizontal, params.sidePadding / 3)
                    .padding(.bottom, params.bottomPadding / 3)
            }
            
            // 特殊效果
            frameSpecialEffects
        }
        .clipShape(RoundedRectangle(cornerRadius: params.cornerRadius))
    }
    
    // 特殊相框效果
    private var frameSpecialEffects: some View {
        Group {
            if frame == .filmStrip {
                // 胶片孔
                VStack {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { _ in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 8, height: 4)
                                .cornerRadius(1)
                        }
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ForEach(0..<3) { _ in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 8, height: 4)
                                .cornerRadius(1)
                        }
                    }
                    .padding(.bottom, 5)
                }
            }
            
            if frame == .polaroidVintage {
                // 复古污渍效果
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.brown.opacity(0.2))
                        .frame(height: 30)
                        .blur(radius: 2)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FrameSelectorView(
            selectedFrame: .constant(.polaroid),
            isPresented: .constant(true)
        )
    }
} 