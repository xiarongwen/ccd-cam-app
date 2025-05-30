//
//  SettingsView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("saveToPhotosAutomatically") private var saveToPhotosAutomatically = true
    @AppStorage("enableHapticFeedback") private var enableHapticFeedback = true
    @AppStorage("enableSoundEffects") private var enableSoundEffects = false
    @AppStorage("defaultFilter") private var defaultFilter = FilterType.none.rawValue
    @AppStorage("photoQuality") private var photoQuality = "high"
    @AppStorage("showWatermark") private var showWatermark = true
    @AppStorage("enableLocationData") private var enableLocationData = false
    
    @State private var showingAbout = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTutorial = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 应用图标和版本信息
                    appHeaderSection
                    
                    // 拍摄设置
                    cameraSettingsSection
                    
                    // 照片设置
                    photoSettingsSection
                    
                    // 界面设置
                    interfaceSettingsSection
                    
                    // 隐私设置
                    privacySettingsSection
                    
                    // 帮助与反馈
                    helpSection
                    
                    // 关于应用
                    aboutSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTutorial) {
            TutorialView()
        }
    }
    
    // MARK: - 应用头部信息
    private var appHeaderSection: some View {
        VStack(spacing: 16) {
            // 应用图标
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                )
                .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 4) {
                Text("CCD复古相机")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("版本 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 拍摄设置
    private var cameraSettingsSection: some View {
        SettingsSection(title: "拍摄设置", icon: "camera") {
            VStack(spacing: 0) {
                SettingsRow(
                    title: "默认滤镜",
                    subtitle: FilterType(rawValue: defaultFilter)?.displayName ?? "无",
                    icon: "camera.filters",
                    action: {
                        // 显示滤镜选择
                    }
                )
                
                Divider().padding(.leading, 48)
                
                SettingsToggleRow(
                    title: "自动保存到相册",
                    subtitle: "拍照后自动保存到系统相册",
                    icon: "square.and.arrow.down",
                    isOn: $saveToPhotosAutomatically
                )
                
                Divider().padding(.leading, 48)
                
                SettingsRow(
                    title: "照片质量",
                    subtitle: photoQuality == "high" ? "高质量" : "标准质量",
                    icon: "photo",
                    action: {
                        photoQuality = photoQuality == "high" ? "standard" : "high"
                    }
                )
            }
        }
    }
    
    // MARK: - 照片设置
    private var photoSettingsSection: some View {
        SettingsSection(title: "照片设置", icon: "photo.on.rectangle") {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "显示水印",
                    subtitle: "在照片上添加时间戳水印",
                    icon: "textformat",
                    isOn: $showWatermark
                )
                
                Divider().padding(.leading, 48)
                
                SettingsToggleRow(
                    title: "保存位置信息",
                    subtitle: "在照片中包含拍摄位置",
                    icon: "location",
                    isOn: $enableLocationData
                )
            }
        }
    }
    
    // MARK: - 界面设置
    private var interfaceSettingsSection: some View {
        SettingsSection(title: "界面设置", icon: "paintbrush") {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "触觉反馈",
                    subtitle: "操作时提供震动反馈",
                    icon: "hand.tap",
                    isOn: $enableHapticFeedback
                )
                
                Divider().padding(.leading, 48)
                
                SettingsToggleRow(
                    title: "声音效果",
                    subtitle: "快门和操作声音",
                    icon: "speaker.wave.2",
                    isOn: $enableSoundEffects
                )
            }
        }
    }
    
    // MARK: - 隐私设置
    private var privacySettingsSection: some View {
        SettingsSection(title: "隐私设置", icon: "hand.raised") {
            VStack(spacing: 0) {
                SettingsRow(
                    title: "相机权限",
                    subtitle: "管理相机访问权限",
                    icon: "camera",
                    action: {
                        openAppSettings()
                    }
                )
                
                Divider().padding(.leading, 48)
                
                SettingsRow(
                    title: "相册权限",
                    subtitle: "管理照片库访问权限",
                    icon: "photo.on.rectangle",
                    action: {
                        openAppSettings()
                    }
                )
                
                Divider().padding(.leading, 48)
                
                SettingsRow(
                    title: "隐私政策",
                    subtitle: "查看我们的隐私政策",
                    icon: "doc.text",
                    action: {
                        showingPrivacyPolicy = true
                    }
                )
            }
        }
    }
    
    // MARK: - 帮助与反馈
    private var helpSection: some View {
        SettingsSection(title: "帮助与反馈", icon: "questionmark.circle") {
            VStack(spacing: 0) {
                SettingsRow(
                    title: "使用教程",
                    subtitle: "学习如何使用应用功能",
                    icon: "play.circle",
                    action: {
                        showingTutorial = true
                    }
                )
                
                Divider().padding(.leading, 48)
                
                SettingsRow(
                    title: "意见反馈",
                    subtitle: "向我们发送反馈和建议",
                    icon: "envelope",
                    action: {
                        sendFeedback()
                    }
                )
                
                Divider().padding(.leading, 48)
                
                SettingsRow(
                    title: "评价应用",
                    subtitle: "在App Store中给我们评分",
                    icon: "star",
                    action: {
                        rateApp()
                    }
                )
            }
        }
    }
    
    // MARK: - 关于应用
    private var aboutSection: some View {
        SettingsSection(title: "关于", icon: "info.circle") {
            VStack(spacing: 0) {
                SettingsRow(
                    title: "关于CCD相机",
                    subtitle: "了解更多应用信息",
                    icon: "camera.vintage",
                    action: {
                        showingAbout = true
                    }
                )
                
                Divider().padding(.leading, 48)
                
                SettingsRow(
                    title: "版本历史",
                    subtitle: "查看更新记录",
                    icon: "clock.arrow.circlepath",
                    action: {
                        // 显示版本历史
                    }
                )
                
                Divider().padding(.leading, 48)
                
                SettingsRow(
                    title: "开源许可",
                    subtitle: "查看第三方许可信息",
                    icon: "doc.text",
                    action: {
                        // 显示开源许可
                    }
                )
            }
        }
    }
    
    // MARK: - 方法
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    private func sendFeedback() {
        if let emailUrl = URL(string: "mailto:feedback@ccdcamera.app?subject=CCD相机反馈") {
            if UIApplication.shared.canOpenURL(emailUrl) {
                UIApplication.shared.open(emailUrl)
            }
        }
    }
    
    private func rateApp() {
        // 这里需要替换为实际的App Store ID
        if let rateUrl = URL(string: "https://apps.apple.com/app/id123456789?action=write-review") {
            if UIApplication.shared.canOpenURL(rateUrl) {
                UIApplication.shared.open(rateUrl)
            }
        }
    }
}

// MARK: - 设置区域组件
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                    .font(.headline)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - 设置行组件
struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - 设置开关行组件
struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Toggle("", isOn: $isOn)
                .tint(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - 关于页面
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 应用介绍
                    VStack(spacing: 16) {
                        Text("CCD复古相机")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("重现90年代CCD数码相机的独特魅力")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // 功能特色
                    VStack(alignment: .leading, spacing: 16) {
                        Text("功能特色")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        FeatureRow(icon: "camera.fill", title: "专业滤镜", description: "15+种精心调制的复古滤镜")
                        FeatureRow(icon: "photo.on.rectangle", title: "实时预览", description: "拍摄时即时查看滤镜效果")
                        FeatureRow(icon: "wand.and.rays", title: "批量处理", description: "一键为多张照片应用相同效果")
                        FeatureRow(icon: "square.and.arrow.up", title: "便捷分享", description: "支持多种社交平台分享")
                    }
                    
                    // 联系信息
                    VStack(alignment: .leading, spacing: 16) {
                        Text("联系我们")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        ContactRow(icon: "envelope", title: "邮箱", value: "support@ccdcamera.app")
                        ContactRow(icon: "globe", title: "官网", value: "www.ccdcamera.app")
                        ContactRow(icon: "message", title: "微信", value: "CCDCamera2024")
                    }
                    
                    // 版权信息
                    VStack(spacing: 8) {
                        Text("© 2024 CCD Camera Team")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("All rights reserved")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - 功能特色行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .font(.title2)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

// MARK: - 联系信息行
struct ContactRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

// MARK: - 隐私政策页面
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("隐私政策")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("最后更新：2024年5月23日")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    privacyContent
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            PolicySection(
                title: "信息收集",
                content: "我们不会收集您的个人信息。所有照片处理都在您的设备上本地完成。"
            )
            
            PolicySection(
                title: "权限使用",
                content: "• 相机权限：用于拍摄照片\n• 相册权限：用于保存和访问照片\n• 位置权限：仅在您开启时用于添加地理标签"
            )
            
            PolicySection(
                title: "数据存储",
                content: "所有照片和设置数据都存储在您的设备上，我们无法访问这些信息。"
            )
            
            PolicySection(
                title: "第三方服务",
                content: "本应用不使用任何第三方分析或广告服务。"
            )
            
            PolicySection(
                title: "联系我们",
                content: "如果您对本隐私政策有任何疑问，请通过 privacy@ccdcamera.app 联系我们。"
            )
        }
    }
}

// MARK: - 政策区域组件
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.yellow)
            
            Text(content)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 教程页面
struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    
    let tutorials = [
        Tutorial(
            title: "拍摄照片",
            description: "点击快门按钮拍摄照片，双击屏幕可以对焦",
            icon: "camera.fill"
        ),
        Tutorial(
            title: "选择滤镜",
            description: "点击滤镜按钮选择不同的复古滤镜效果",
            icon: "camera.filters"
        ),
        Tutorial(
            title: "编辑照片",
            description: "拍照后可以添加相框、水印等效果",
            icon: "photo"
        ),
        Tutorial(
            title: "批量处理",
            description: "在相册中选择多张照片进行批量处理",
            icon: "wand.and.rays"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // 关闭按钮
                HStack {
                    Spacer()
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
                .padding()
                
                // 教程内容
                TabView(selection: $currentPage) {
                    ForEach(0..<tutorials.count, id: \.self) { index in
                        TutorialCard(tutorial: tutorials[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // 底部按钮
                HStack {
                    if currentPage > 0 {
                        Button("上一步") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if currentPage < tutorials.count - 1 {
                        Button("下一步") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .foregroundColor(.yellow)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - 教程数据模型
struct Tutorial {
    let title: String
    let description: String
    let icon: String
}

// MARK: - 教程卡片
struct TutorialCard: View {
    let tutorial: Tutorial
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: tutorial.icon)
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            VStack(spacing: 16) {
                Text(tutorial.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(tutorial.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView()
} 