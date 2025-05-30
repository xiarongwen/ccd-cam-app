//
//  LaunchScreenView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var showMainView = false
    
    var body: some View {
        ZStack {
            // 背景 - 模拟老相机的纹理
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo区域
                ZStack {
                    // 外圈装饰
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(white: 0.3), Color(white: 0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // 相机镜头效果
                    ZStack {
                        // 镜头外环
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(white: 0.2), Color(white: 0.1)],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 70
                                )
                            )
                            .frame(width: 140, height: 140)
                        
                        // 镜头光圈叶片
                        ForEach(0..<8) { i in
                            Capsule()
                                .fill(Color(white: 0.15))
                                .frame(width: 3, height: 40)
                                .offset(y: -35)
                                .rotationEffect(.degrees(Double(i) * 45))
                        }
                        
                        // 镜头中心
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(white: 0.6), Color(white: 0.3)],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color(white: 0.7), lineWidth: 2)
                            )
                        
                        // 反光效果
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 15, height: 15)
                            .offset(x: -10, y: -10)
                    }
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                // 文字部分
                VStack(spacing: 10) {
                    Text("CCD")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    Text("FILM CAMERA")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.7))
                        .tracking(3)
                }
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeIn(duration: 1).delay(0.5), value: isAnimating)
                
                // 加载指示器
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .padding(.top, 40)
            }
            
            // 装饰性元素 - 模拟取景器的四角
            VStack {
                HStack {
                    ViewfinderCorner()
                    Spacer()
                    ViewfinderCorner()
                        .rotationEffect(.degrees(90))
                }
                Spacer()
                HStack {
                    ViewfinderCorner()
                        .rotationEffect(.degrees(-90))
                    Spacer()
                    ViewfinderCorner()
                        .rotationEffect(.degrees(180))
                }
            }
            .padding(40)
            .opacity(0.5)
        }
        .onAppear {
            isAnimating = true
            
            // 3秒后进入主界面
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMainView = true
                }
            }
        }
        .fullScreenCover(isPresented: $showMainView) {
            ContentView()
        }
    }
}

// 取景器角标记组件
struct ViewfinderCorner: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 30))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 30, y: 0))
        }
        .stroke(Color.yellow.opacity(0.8), lineWidth: 3)
        .frame(width: 30, height: 30)
    }
}

#Preview {
    LaunchScreenView()
} 