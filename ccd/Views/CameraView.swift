//
//  CameraView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI
import AVFoundation

// MARK: - 调试日志工具
#if DEBUG
private func debugLog(_ message: String, category: String = "CameraView") {
    print("[\(category)] \(message)")
}
#else
private func debugLog(_ message: String, category: String = "CameraView") {
    // Release模式下不输出日志
}
#endif

struct CameraView: View {
    @StateObject private var cameraService = CameraService()
    @State private var currentFilter: FilterType = .none
    @State private var showFilterSelector = false
    @State private var focusPoint: CGPoint? = nil
    @State private var captureAnimation = false
    @State private var shutterAnimation = false
    @State private var capturedImage: UIImage? = nil
    @State private var showPhotoEditor = false
    @State private var showGallery = false
    @State private var showBatchProcess = false
    @State private var showSettings = false
    
    // 当前主题，基于选择的滤镜
    private var currentTheme: CameraTheme {
        currentFilter.cameraTheme
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 动态背景色 - 根据当前滤镜主题变化
                currentTheme.backgroundColor
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.8), value: currentFilter)
                
                VStack(spacing: 0) {
                    // 顶部相机机身装饰
                    topCameraBody
                    
                    // 相机主体
                    cameraMainBody
                    
                    // 底部控制面板
                    bottomControlPanel
                }
            }
            .onAppear {
                debugLog("CameraView appeared")
                Task {
                    await MainActor.run {
                        cameraService.startSession()
                        cameraService.updateFilter(currentFilter)
                    }
                }
            }
            .onDisappear {
                debugLog("CameraView disappeared")
                cameraService.stopSession()
            }
            .onChange(of: currentFilter) { newFilter in
                cameraService.updateFilter(newFilter)
                debugLog("Filter updated to: \(newFilter.displayName)")
                
                // 添加主题切换的触觉反馈
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            .statusBarHidden(true)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showPhotoEditor) {
            if let image = capturedImage {
                PhotoEditView(originalImage: image)
            }
        }
        .fullScreenCover(isPresented: $showGallery) {
            GalleryView()
        }
        .fullScreenCover(isPresented: $showBatchProcess) {
            BatchProcessView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
        .overlay(
            // 滤镜选择器
            Group {
                if showFilterSelector {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showFilterSelector = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        FilterSelectorView(
                            selectedFilter: $currentFilter,
                            isPresented: $showFilterSelector,
                            previewImage: cameraService.previewImage
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                }
            }
        )
    }
    
    // MARK: - 顶部相机机身
    private var topCameraBody: some View {
        VStack(spacing: 0) {
            // 品牌标识区域 - 动态主题
            HStack {
                Spacer()
                
                // 动态品牌标识
                VStack(spacing: 2) {
                    Text(currentTheme.brandSubtitle)
                        .font(currentTheme.indicatorStyle.font)
                        .foregroundColor(currentTheme.brandColor)
                        .animation(.easeInOut(duration: 0.6), value: currentFilter)
                    
                    Text(currentTheme.brandName)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(currentTheme.brandColor)
                        .tracking(2)
                        .animation(.easeInOut(duration: 0.6), value: currentFilter)
                }
                .padding(.top, 50)
                
                Spacer()
            }
            
            // 顶部控制区域
            HStack(spacing: 30) {
                // 设置按钮 - 主题化
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(currentTheme.indicatorStyle.textColor)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(currentTheme.indicatorStyle.backgroundColor)
                                .overlay(
                                    Circle()
                                        .stroke(currentTheme.indicatorStyle.borderColor, lineWidth: 1)
                                )
                        )
                }
                
                // 闪光灯指示器 - 主题化
                ThemeFlashIndicator(
                    flashMode: $cameraService.flashMode,
                    theme: currentTheme
                )
                
                Spacer()
                
                // 相机切换按钮 - 主题化
                ThemeVintageSwitch(
                    theme: currentTheme,
                    onToggle: {
                        cameraService.switchCamera()
                    }
                )
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .frame(height: 140)
    }
    
    // MARK: - 相机主体
    private var cameraMainBody: some View {
        VStack(spacing: 20) {
            // 主镜头区域 - 主题化
            ThemedMainLens(
                theme: currentTheme,
                onTap: {
                    let center = CGPoint(x: 0.5, y: 0.5)
                    cameraService.focus(at: center)
                }
            )
            
            // 取景器和控制面板
            HStack(spacing: 20) {
                // 左侧控制面板 - 主题化
                ThemedLeftControlPanel(theme: currentTheme)
                
                Spacer()
                
                // 取景器 - 主题化
                ThemedViewfinder(
                    theme: currentTheme,
                    currentFilter: currentFilter,
                    shutterAnimation: shutterAnimation,
                    session: cameraService.session,
                    focusPoint: $focusPoint,
                    cameraService: cameraService
                )
                
                Spacer()
                
                // 右侧控制面板 - 主题化
                ThemedRightControlPanel(theme: currentTheme)
            }
            .padding(.horizontal, 30)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 底部控制面板
    private var bottomControlPanel: some View {
        VStack(spacing: 20) {
            // 胶片装载指示器 - 主题化
            ThemedFilmLoadIndicator(theme: currentTheme)
            
            // 主要控制按钮
            HStack(spacing: 30) {
                // 批量处理按钮 - 主题化
                ThemedControlButton(
                    icon: "square.grid.3x2",
                    label: "BATCH",
                    theme: currentTheme,
                    isActive: false
                ) {
                    showBatchProcess = true
                }
                
                // 相册按钮 - 主题化
                ThemedControlButton(
                    icon: "photo.on.rectangle",
                    label: "ALBUM",
                    theme: currentTheme,
                    isActive: false
                ) {
                    showGallery = true
                }
                
                // 快门按钮 - 主题化
                ThemedShutterButton(
                    theme: currentTheme,
                    captureAnimation: captureAnimation,
                    onCapture: capturePhoto
                )
                
                // 滤镜按钮 - 主题化
                ThemedControlButton(
                    icon: "camera.filters",
                    label: "FILTER",
                    theme: currentTheme,
                    isActive: showFilterSelector
                ) {
                    withAnimation(.spring()) {
                        showFilterSelector.toggle()
                    }
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                
                // 额外功能按钮（可以是设置的另一个入口或其他功能）
                ThemedControlButton(
                    icon: "ellipsis",
                    label: "MORE",
                    theme: currentTheme,
                    isActive: false
                ) {
                    // 可以显示更多功能菜单或直接打开设置
                    showSettings = true
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - 拍照方法
    private func capturePhoto() {
        debugLog("Starting photo capture")
        
        guard cameraService.isAuthorized else {
            debugLog("Camera not authorized", category: "Error")
            return
        }
        
        guard cameraService.isSessionRunning else {
            debugLog("Camera session not running", category: "Error")
            return
        }
        
        guard !cameraService.isCapturing else {
            debugLog("Already capturing photo", category: "Warning")
            return
        }
        
        // 触感反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // 快门动画
        withAnimation(.easeInOut(duration: 0.15)) {
            captureAnimation = true
            shutterAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.captureAnimation = false
            self.shutterAnimation = false
        }
        
        // 拍照
        cameraService.capturePhoto { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    debugLog("Photo capture successful")
                    self.capturedImage = image
                    self.showPhotoEditor = true
                    
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                    
                case .failure(let error):
                    debugLog("Photo capture failed: \(error)", category: "Error")
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.error)
                }
            }
        }
    }
}

// MARK: - 主题化组件

// 主题化闪光灯指示器
struct ThemeFlashIndicator: View {
    @Binding var flashMode: AVCaptureDevice.FlashMode
    let theme: CameraTheme
    
    var body: some View {
        Button(action: toggleFlash) {
            HStack(spacing: 5) {
                Image(systemName: flashIcon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(flashColor)
                
                Text(flashText)
                    .font(theme.indicatorStyle.font)
                    .foregroundColor(flashColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(theme.indicatorStyle.backgroundColor)
                    .overlay(
                        Capsule()
                            .stroke(theme.indicatorStyle.borderColor, lineWidth: 1)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.3), value: flashMode)
    }
    
    private func toggleFlash() {
        switch flashMode {
        case .off: flashMode = .auto
        case .auto: flashMode = .on
        case .on: flashMode = .off
        @unknown default: flashMode = .off
        }
    }
    
    private var flashIcon: String {
        switch flashMode {
        case .off: return "bolt.slash"
        case .on: return "bolt.fill"
        case .auto: return "bolt.badge.a"
        @unknown default: return "bolt.slash"
        }
    }
    
    private var flashText: String {
        switch flashMode {
        case .off: return "OFF"
        case .on: return "ON"
        case .auto: return "AUTO"
        @unknown default: return "OFF"
        }
    }
    
    private var flashColor: Color {
        switch flashMode {
        case .off: return theme.indicatorStyle.textColor
        case .on: return theme.indicatorStyle.accentColor
        case .auto: return theme.buttonStyle.activeColor
        @unknown default: return theme.indicatorStyle.textColor
        }
    }
}

// 主题化复古开关
struct ThemeVintageSwitch: View {
    let theme: CameraTheme
    let onToggle: () -> Void
    @State private var isToggled = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isToggled.toggle()
            }
            onToggle()
        }) {
            HStack(spacing: 4) {
                Circle()
                    .fill(isToggled ? theme.indicatorStyle.accentColor : theme.indicatorStyle.textColor)
                    .frame(width: 8, height: 8)
                
                Text("F/R")
                    .font(theme.indicatorStyle.font)
                    .foregroundColor(theme.indicatorStyle.textColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(theme.indicatorStyle.backgroundColor)
                    .overlay(
                        Capsule()
                            .stroke(theme.indicatorStyle.borderColor, lineWidth: 1)
                    )
            )
        }
        .animation(.spring(response: 0.3), value: isToggled)
    }
}

// 主题化主镜头
struct ThemedMainLens: View {
    let theme: CameraTheme
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // 镜头外环 - 主题化
            Circle()
                .fill(theme.lensStyle.outerColor)
                .frame(width: theme.lensStyle.size, height: theme.lensStyle.size)
                .overlay(
                    Circle()
                        .stroke(theme.lensStyle.borderColor, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // 镜头内环
            Circle()
                .fill(theme.lensStyle.innerColor)
                .frame(width: 200, height: 200)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(white: 0.8), Color(white: 0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
            
            // 镜头玻璃反射效果 - 主题化
            Circle()
                .fill(
                    RadialGradient(
                        colors: theme.lensStyle.reflectionColors + [Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
            
            // 镜头文字 - 主题化
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(theme.lensStyle.markingText)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.lensStyle.markingColor)
                        .rotationEffect(.degrees(-15))
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .frame(width: 180, height: 180)
            
            // 镜头中心光斑
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)
        }
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.8), value: theme.id)
    }
}

// 主题化取景器
struct ThemedViewfinder: View {
    let theme: CameraTheme
    let currentFilter: FilterType
    let shutterAnimation: Bool
    let session: AVCaptureSession
    @Binding var focusPoint: CGPoint?
    let cameraService: CameraService
    
    var body: some View {
        VStack(spacing: 8) {
            // 取景器标签 - 主题化
            Text("VIEWFINDER")
                .font(theme.indicatorStyle.font)
                .foregroundColor(theme.indicatorStyle.textColor)
                .opacity(0.7)
            
            // 取景器窗口
            ZStack {
                // 取景器边框
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black)
                    .frame(width: 100, height: 75)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.indicatorStyle.borderColor, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
                
                // 相机预览 (缩小版)
                CameraPreviewView(
                    session: session,
                    focusPoint: $focusPoint,
                    cameraService: cameraService,
                    onTap: { point in
                        cameraService.focus(at: point)
                    },
                    onPinch: { scale in
                        cameraService.zoom(factor: scale)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .frame(width: 96, height: 71)
                
                // 取景器十字线 - 主题化
                Path { path in
                    // 水平线
                    path.move(to: CGPoint(x: 30, y: 37.5))
                    path.addLine(to: CGPoint(x: 70, y: 37.5))
                    // 垂直线
                    path.move(to: CGPoint(x: 50, y: 20))
                    path.addLine(to: CGPoint(x: 50, y: 55))
                }
                .stroke(theme.indicatorStyle.accentColor.opacity(0.5), lineWidth: 0.5)
                .frame(width: 96, height: 71)
                
                // 快门动画效果
                if shutterAnimation {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                        .frame(width: 96, height: 71)
                        .opacity(0.8)
                        .transition(.opacity)
                }
            }
            
            // 当前滤镜显示 - 主题化
            Text(currentFilter.displayName)
                .font(theme.indicatorStyle.font)
                .foregroundColor(theme.indicatorStyle.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(theme.indicatorStyle.backgroundColor)
                )
        }
        .animation(.easeInOut(duration: 0.6), value: theme.id)
    }
}

// 主题化左侧控制面板
struct ThemedLeftControlPanel: View {
    let theme: CameraTheme
    
    var body: some View {
        VStack(spacing: 15) {
            // ISO 设置 - 主题化
            ThemedVintageKnob(value: 400, label: "ISO", unit: "", theme: theme)
            
            // 快门速度 - 主题化
            ThemedVintageKnob(value: 60, label: "1/", unit: "s", theme: theme)
        }
    }
}

// 主题化右侧控制面板
struct ThemedRightControlPanel: View {
    let theme: CameraTheme
    
    var body: some View {
        VStack(spacing: 15) {
            // 光圈设置 - 主题化
            ThemedVintageKnob(value: 2.8, label: "f/", unit: "", theme: theme)
            
            // 测光表 - 主题化
            ThemedLightMeter(theme: theme)
        }
    }
}

// 主题化复古旋钮
struct ThemedVintageKnob: View {
    let value: Double
    let label: String
    let unit: String
    let theme: CameraTheme
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(theme.indicatorStyle.font)
                .foregroundColor(theme.indicatorStyle.textColor)
                .opacity(0.7)
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [theme.buttonStyle.controlColor.opacity(0.8), theme.buttonStyle.controlColor.opacity(0.6)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(theme.indicatorStyle.borderColor, lineWidth: 1)
                    )
                
                // 旋钮指示器
                Rectangle()
                    .fill(theme.indicatorStyle.textColor)
                    .frame(width: 1, height: 8)
                    .offset(y: -8)
                    .rotationEffect(.degrees(value * 3.6))
            }
            
            Text("\(label)\(Int(value))\(unit)")
                .font(.system(size: 6, weight: .medium, design: .monospaced))
                .foregroundColor(theme.indicatorStyle.textColor)
        }
        .animation(.easeInOut(duration: 0.6), value: theme.id)
    }
}

// 主题化测光表
struct ThemedLightMeter: View {
    let theme: CameraTheme
    
    var body: some View {
        VStack(spacing: 4) {
            Text("LIGHT")
                .font(theme.indicatorStyle.font)
                .foregroundColor(theme.indicatorStyle.textColor)
                .opacity(0.7)
            
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black)
                    .frame(width: 30, height: 20)
                
                // 模拟测光条 - 主题化
                HStack(spacing: 1) {
                    ForEach(0..<5) { index in
                        Rectangle()
                            .fill(index < 3 ? theme.indicatorStyle.accentColor : theme.indicatorStyle.accentColor.opacity(0.3))
                            .frame(width: 3, height: 12)
                    }
                }
            }
            
            Text("METER")
                .font(.system(size: 6, weight: .medium, design: .monospaced))
                .foregroundColor(theme.indicatorStyle.textColor)
        }
        .animation(.easeInOut(duration: 0.6), value: theme.id)
    }
}

// 主题化胶片装载指示器
struct ThemedFilmLoadIndicator: View {
    let theme: CameraTheme
    
    var body: some View {
        HStack(spacing: 10) {
            // 胶片盒图标
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 16))
                .foregroundColor(theme.indicatorStyle.textColor)
            
            // 胶片计数
            Text("36 EXP")
                .font(theme.indicatorStyle.font)
                .foregroundColor(theme.indicatorStyle.textColor)
            
            // 分隔线
            Rectangle()
                .fill(theme.indicatorStyle.textColor)
                .frame(width: 20, height: 1)
            
            // 拍摄计数
            Text("001")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(theme.indicatorStyle.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.indicatorStyle.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(theme.indicatorStyle.borderColor, lineWidth: 1)
                        )
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.indicatorStyle.backgroundColor.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.indicatorStyle.borderColor, lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.6), value: theme.id)
    }
}

// 主题化快门按钮
struct ThemedShutterButton: View {
    let theme: CameraTheme
    let captureAnimation: Bool
    let onCapture: () -> Void
    
    var body: some View {
        Button(action: onCapture) {
            ZStack {
                // 外环 - 主题化
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.9), Color(white: 0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(theme.buttonStyle.shutterBorder, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.3), radius: theme.buttonStyle.shadowRadius, x: 0, y: 4)
                
                // 内环 - 主题化
                Circle()
                    .fill(theme.buttonStyle.shutterColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(theme.buttonStyle.shutterBorder, lineWidth: 2)
                    )
                
                // 快门标识
                Text("⚫")
                    .font(.system(size: 12))
                    .foregroundColor(theme.buttonStyle.shutterBorder)
            }
        }
        .scaleEffect(captureAnimation ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: captureAnimation)
        .animation(.easeInOut(duration: 0.8), value: theme.id)
    }
}

// 主题化控制按钮
struct ThemedControlButton: View {
    let icon: String
    let label: String
    let theme: CameraTheme
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(theme.indicatorStyle.backgroundColor)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isActive ? theme.buttonStyle.activeColor : theme.buttonStyle.controlColor, lineWidth: isActive ? 2 : 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isActive ? theme.buttonStyle.activeColor : theme.buttonStyle.controlColor)
                    
                    if isActive {
                        Circle()
                            .fill(theme.buttonStyle.activeColor)
                            .frame(width: 6, height: 6)
                            .offset(x: 15, y: -15)
                    }
                }
                
                Text(label)
                    .font(theme.indicatorStyle.font)
                    .foregroundColor(isActive ? theme.buttonStyle.activeColor : theme.buttonStyle.controlColor)
            }
        }
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .animation(.easeInOut(duration: 0.6), value: theme.id)
    }
}

#Preview {
    CameraView()
} 