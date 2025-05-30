//
//  ShareView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI
import UIKit

struct ShareView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    
    @State private var shareText: String = "用CCD复古相机拍摄 📸✨ #CCD #复古摄影 #胶片质感"
    @State private var showingShareSheet = false
    @State private var selectedShareOption: ShareOption?
    @State private var showingCustomShareSheet = false
    
    enum ShareOption: String, CaseIterable {
        case systemShare = "system"
        case instagram = "instagram"
        case wechat = "wechat"
        case weibo = "weibo"
        case xiaohongshu = "xiaohongshu"
        case telegram = "telegram"
        case twitter = "twitter"
        case saveToPhotos = "save"
        
        var displayName: String {
            switch self {
            case .systemShare: return "更多应用"
            case .instagram: return "Instagram"
            case .wechat: return "微信"
            case .weibo: return "微博"
            case .xiaohongshu: return "小红书"
            case .telegram: return "Telegram"
            case .twitter: return "Twitter"
            case .saveToPhotos: return "保存到相册"
            }
        }
        
        var iconName: String {
            switch self {
            case .systemShare: return "square.and.arrow.up"
            case .instagram: return "camera"
            case .wechat: return "message"
            case .weibo: return "bubble.left.and.bubble.right"
            case .xiaohongshu: return "book"
            case .telegram: return "paperplane"
            case .twitter: return "bird"
            case .saveToPhotos: return "square.and.arrow.down"
            }
        }
        
        var color: Color {
            switch self {
            case .systemShare: return .blue
            case .instagram: return .purple
            case .wechat: return .green
            case .weibo: return .orange
            case .xiaohongshu: return .red
            case .telegram: return .blue
            case .twitter: return .blue
            case .saveToPhotos: return .gray
            }
        }
        
        var urlScheme: String? {
            switch self {
            case .instagram: return "instagram://app"
            case .wechat: return "weixin://"
            case .weibo: return "sinaweibo://"
            case .xiaohongshu: return "xhsdiscover://"
            case .telegram: return "tg://"
            case .twitter: return "twitter://"
            default: return nil
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                // 顶部控制栏
                topControlBar
                
                // 照片预览
                photoPreview
                
                // 分享文本编辑
                shareTextEditor
                
                // 分享选项
                shareOptionsGrid
                
                // 底部操作栏
                bottomActionBar
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.1))
            )
            .padding()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareOption = selectedShareOption {
                ActivityViewController(
                    activityItems: createShareItems(for: shareOption),
                    applicationActivities: nil
                )
            }
        }
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack {
            Button("取消") {
                isPresented = false
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Text("分享照片")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Button("完成") {
                isPresented = false
            }
            .foregroundColor(.yellow)
        }
        .padding()
    }
    
    // MARK: - 照片预览
    private var photoPreview: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text("分辨率: \(Int(image.size.width)) × \(Int(image.size.height))")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
        .padding(.horizontal)
    }
    
    // MARK: - 分享文本编辑
    private var shareTextEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("分享文案")
                .font(.headline)
                .foregroundColor(.white)
            
            TextEditor(text: $shareText)
                .padding(12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .frame(height: 80)
                .foregroundColor(.white)
                .font(.body)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            HStack {
                Text("\(shareText.count)/200")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button("清空") {
                    shareText = ""
                }
                .font(.caption)
                .foregroundColor(.yellow)
                
                Button("重置") {
                    shareText = "用CCD复古相机拍摄 📸✨ #CCD #复古摄影 #胶片质感"
                }
                .font(.caption)
                .foregroundColor(.yellow)
                .padding(.leading, 8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    // MARK: - 分享选项网格
    private var shareOptionsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("分享到")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 16
            ) {
                ForEach(ShareOption.allCases, id: \.self) { option in
                    ShareOptionButton(
                        option: option,
                        isAvailable: isAppAvailable(option),
                        action: {
                            handleShareOption(option)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - 底部操作栏
    private var bottomActionBar: some View {
        VStack(spacing: 12) {
            // 快速分享按钮
            HStack(spacing: 12) {
                Button(action: {
                    handleShareOption(.saveToPhotos)
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("保存")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    handleShareOption(.systemShare)
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("系统分享")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            // 提示文本
            Text("提示：首次分享到某些应用可能需要安装对应的App")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.bottom)
    }
    
    // MARK: - 方法
    private func isAppAvailable(_ option: ShareOption) -> Bool {
        guard let urlScheme = option.urlScheme,
              let url = URL(string: urlScheme) else {
            return true // 系统功能总是可用
        }
        
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func handleShareOption(_ option: ShareOption) {
        selectedShareOption = option
        
        switch option {
        case .saveToPhotos:
            saveToPhotos()
        case .systemShare:
            showSystemShareSheet()
        default:
            shareToSpecificApp(option)
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func saveToPhotos() {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // 显示保存成功提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPresented = false
        }
    }
    
    private func showSystemShareSheet() {
        showingShareSheet = true
    }
    
    private func shareToSpecificApp(_ option: ShareOption) {
        guard let urlScheme = option.urlScheme,
              let url = URL(string: urlScheme) else {
            // 如果没有URL scheme，使用系统分享
            showSystemShareSheet()
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            // 应用已安装，使用特定的分享方式
            switch option {
            case .instagram:
                shareToInstagram()
            case .wechat:
                shareToWeChat()
            default:
                // 其他应用使用系统分享
                showSystemShareSheet()
            }
        } else {
            // 应用未安装，提示用户安装或使用系统分享
            showAppNotInstalledAlert(for: option)
        }
    }
    
    private func shareToInstagram() {
        // Instagram Stories分享
        guard let urlScheme = URL(string: "instagram-stories://share") else {
            showSystemShareSheet()
            return
        }
        
        if UIApplication.shared.canOpenURL(urlScheme) {
            // 保存图片到剪贴板，Instagram会自动读取
            UIPasteboard.general.image = image
            UIApplication.shared.open(urlScheme)
        } else {
            showSystemShareSheet()
        }
    }
    
    private func shareToWeChat() {
        // 微信分享需要集成微信SDK，这里使用系统分享作为替代
        showSystemShareSheet()
    }
    
    private func showAppNotInstalledAlert(for option: ShareOption) {
        // 这里可以显示一个Alert提示用户安装应用
        // 暂时使用系统分享作为备选方案
        showSystemShareSheet()
    }
    
    private func createShareItems(for option: ShareOption) -> [Any] {
        var items: [Any] = [image]
        
        if !shareText.isEmpty {
            items.append(shareText)
        }
        
        return items
    }
}

// MARK: - 分享选项按钮
struct ShareOptionButton: View {
    let option: ShareView.ShareOption
    let isAvailable: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isAvailable ? option.color : Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: option.iconName)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Text(option.displayName)
                    .font(.caption)
                    .foregroundColor(isAvailable ? .white : .gray)
                    .lineLimit(1)
            }
        }
        .disabled(!isAvailable)
        .scaleEffect(isAvailable ? 1.0 : 0.9)
        .opacity(isAvailable ? 1.0 : 0.6)
    }
}

// MARK: - 系统分享控制器
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        // 排除一些不需要的活动类型
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .markupAsPDF
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新
    }
}

// MARK: - 分享成功提示
struct ShareSuccessToast: View {
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            if isPresented {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text(message)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .padding(.bottom, 50)
                    
                    Spacer()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
        .animation(.spring(), value: isPresented)
    }
}

#Preview {
    ShareView(
        image: UIImage(systemName: "photo") ?? UIImage(),
        isPresented: .constant(true)
    )
} 