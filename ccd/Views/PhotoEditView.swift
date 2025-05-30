//
//  PhotoEditView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI
import Photos

struct PhotoEditView: View {
    let originalImage: UIImage
    @State private var currentFilter: FilterType = .none
    @State private var currentFrame: FrameType = .polaroid
    @State private var currentWatermark: WatermarkType = .timestamp
    @State private var customWatermarkText: String = ""
    @State private var showFilterSelector = false
    @State private var showFrameSelector = false
    @State private var showWatermarkSelector = false
    @State private var showCustomTextEditor = false
    @State private var isProcessing = false
    @State private var showSaveSuccess = false
    @State private var showShareView = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar
                
                // 预览区域
                photoPreviewArea
                
                Spacer()
                
                // 编辑工具栏
                editingToolbar
                
                // 底部操作栏
                bottomActionBar
            }
            
            // 选择器覆盖层
            if showFilterSelector {
                filterSelectorOverlay
            }
            
            if showFrameSelector {
                frameSelectorOverlay
            }
            
            if showWatermarkSelector {
                watermarkSelectorOverlay
            }
            
            if showCustomTextEditor {
                customTextEditorOverlay
            }
            
            // 处理中指示器
            if isProcessing {
                processingOverlay
            }
            
            // 保存成功提示
            if showSaveSuccess {
                saveSuccessOverlay
            }
            
            // 分享视图
            if showShareView {
                shareViewOverlay
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - 顶部导航栏
    private var topNavigationBar: some View {
        HStack {
            Button("取消") {
                dismiss()
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Text("照片编辑")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 15) {
                // 分享按钮
                Button(action: {
                    showShareView = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                Button("保存") {
                    savePhoto()
                }
                .foregroundColor(.yellow)
                .disabled(isProcessing)
            }
        }
        .padding()
    }
    
    // MARK: - 预览区域
    private var photoPreviewArea: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                PhotoPreviewWithFrame(
                    image: originalImage,
                    filter: currentFilter,
                    frame: currentFrame,
                    watermark: currentWatermark,
                    customText: customWatermarkText
                )
                .frame(
                    width: min(geometry.size.width - 40, 400),
                    height: min(geometry.size.height - 40, 500)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 编辑工具栏
    private var editingToolbar: some View {
        HStack(spacing: 30) {
            // 滤镜按钮
            ToolButton(
                icon: "camera.filters",
                title: "滤镜",
                isSelected: showFilterSelector
            ) {
                showFilterSelector = true
            }
            
            // 相框按钮
            ToolButton(
                icon: "rectangle.portrait",
                title: "相框",
                isSelected: showFrameSelector
            ) {
                showFrameSelector = true
            }
            
            // 水印按钮
            ToolButton(
                icon: "textformat",
                title: "水印",
                isSelected: showWatermarkSelector
            ) {
                showWatermarkSelector = true
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 底部操作栏
    private var bottomActionBar: some View {
        HStack {
            // 当前设置显示
            VStack(alignment: .leading, spacing: 4) {
                Text("滤镜: \(currentFilter.displayName)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("相框: \(currentFrame.displayName)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("水印: \(currentWatermark.displayName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 重置按钮
            Button("重置") {
                resetToDefaults()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: 0.2))
            )
        }
        .padding()
    }
    
    // MARK: - 选择器覆盖层
    private var filterSelectorOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    showFilterSelector = false
                }
            
            VStack {
                Spacer()
                FilterSelectorView(
                    selectedFilter: $currentFilter,
                    isPresented: $showFilterSelector,
                    previewImage: CIImage(image: originalImage)
                )
            }
        }
    }
    
    private var frameSelectorOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    showFrameSelector = false
                }
            
            VStack {
                Spacer()
                FrameSelectorView(
                    selectedFrame: $currentFrame,
                    isPresented: $showFrameSelector
                )
            }
        }
    }
    
    private var watermarkSelectorOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    showWatermarkSelector = false
                }
            
            VStack {
                Spacer()
                WatermarkSelectorView(
                    selectedWatermark: $currentWatermark,
                    isPresented: $showWatermarkSelector,
                    onCustomTextTap: {
                        showWatermarkSelector = false
                        showCustomTextEditor = true
                    }
                )
            }
        }
    }
    
    private var customTextEditorOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    showCustomTextEditor = false
                }
            
            VStack {
                Spacer()
                CustomTextEditorView(
                    text: $customWatermarkText,
                    isPresented: $showCustomTextEditor
                )
                Spacer()
            }
        }
    }
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("正在保存...")
                    .foregroundColor(.white)
                    .padding(.top)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.1))
            )
        }
    }
    
    private var saveSuccessOverlay: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("保存成功！")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.top)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSaveSuccess = false
                dismiss()
            }
        }
    }
    
    private var shareViewOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    showShareView = false
                }
            
            VStack {
                Spacer()
                ShareView(
                    image: createFinalImage(),
                    isPresented: $showShareView
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func resetToDefaults() {
        currentFilter = .none
        currentFrame = .polaroid
        currentWatermark = .timestamp
        customWatermarkText = ""
    }
    
    private func savePhoto() {
        print("💾 开始保存照片...")
        
        // 确保在主线程上执行UI相关操作
        guard Thread.isMainThread else {
            print("💾 警告：savePhoto不在主线程，切换到主线程")
            DispatchQueue.main.async {
                self.savePhoto()
            }
            return
        }
        
        isProcessing = true
        
        // 检查权限
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        print("💾 当前权限状态: \(status.rawValue)")
        
        switch status {
        case .authorized, .limited:
            // 已有权限，直接保存
            performSave()
        case .notDetermined:
            // 请求权限
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    print("💾 权限请求结果: \(newStatus.rawValue)")
                    if newStatus == .authorized || newStatus == .limited {
                        self.performSave()
                    } else {
                        self.isProcessing = false
                        print("💾 用户拒绝了相册权限")
                        // TODO: 显示权限被拒绝的提示
                    }
                }
            }
        case .denied, .restricted:
            isProcessing = false
            print("💾 相册权限被拒绝或受限")
            // TODO: 显示需要在设置中开启权限的提示
        @unknown default:
            isProcessing = false
            print("💾 未知的权限状态")
        }
    }
    
    private func performSave() {
        print("💾 开始执行保存...")
        
        // 首先在主线程上创建图片
        let processedImage = createFinalImage()
        print("💾 图片处理完成，大小: \(processedImage.size)")
        
        // 然后在后台线程保存到相册
        DispatchQueue.global(qos: .userInitiated).async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
            }) { success, error in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    if success {
                        print("💾 保存成功!")
                        self.showSaveSuccess = true
                    } else {
                        print("💾 保存失败: \(error?.localizedDescription ?? "未知错误")")
                        // TODO: 显示保存失败的提示
                    }
                }
            }
        }
    }
    
    private func createFinalImage() -> UIImage {
        print("🎨 开始创建最终图片...")
        
        // 首先应用滤镜
        let filteredImage: UIImage
        if currentFilter != .none {
            print("🎨 应用滤镜: \(currentFilter.displayName)")
            filteredImage = FilterEngine.shared.applyFilter(to: originalImage, filterType: currentFilter) ?? originalImage
        } else {
            filteredImage = originalImage
        }
        
        print("🎨 创建相框预览...")
        
        // 创建预览视图 - 必须在主线程上
        let previewView = PhotoPreviewWithFrame(
            image: filteredImage,
            filter: .none, // 滤镜已应用
            frame: currentFrame,
            watermark: currentWatermark,
            customText: customWatermarkText
        )
        .frame(width: 400, height: 500)
        
        // 尝试使用 ImageRenderer 渲染 - 必须在主线程上
        let renderer = ImageRenderer(content: previewView)
        renderer.scale = 3.0 // 高分辨率
        
        if let renderedImage = renderer.uiImage {
            print("🎨 ImageRenderer 渲染成功")
            return renderedImage
        } else {
            print("🎨 ImageRenderer 渲染失败，使用备用方法")
            return createImageWithUIKit(filteredImage: filteredImage)
        }
    }
    
    // 备用的图片合成方法
    private func createImageWithUIKit(filteredImage: UIImage) -> UIImage {
        print("🎨 使用 UIKit 方法创建图片...")
        
        // 确保在主线程上执行UI相关操作
        guard Thread.isMainThread else {
            print("🎨 警告：createImageWithUIKit不在主线程")
            // 如果不在主线程，返回原图作为备用
            return filteredImage
        }
        
        let finalSize = CGSize(width: 400, height: 500)
        let frameParams = currentFrame.frameParams
        
        let renderer = UIGraphicsImageRenderer(size: finalSize)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 1. 绘制相框背景
            cgContext.setFillColor(UIColor(frameParams.color).cgColor)
            cgContext.fill(CGRect(origin: .zero, size: finalSize))
            
            // 2. 计算照片区域
            let photoRect = CGRect(
                x: frameParams.sidePadding,
                y: frameParams.topPadding,
                width: finalSize.width - frameParams.sidePadding * 2,
                height: finalSize.height - frameParams.topPadding - frameParams.bottomPadding
            )
            
            // 3. 绘制照片
            filteredImage.draw(in: photoRect)
            
            // 4. 绘制水印
            if currentWatermark != .none {
                drawWatermark(in: photoRect, context: cgContext)
            }
            
            // 5. 绘制胶片孔（如果是胶片条相框）
            if currentFrame == .filmStrip {
                drawFilmHoles(in: CGRect(origin: .zero, size: finalSize), context: cgContext)
            }
        }
    }
    
    // 绘制水印
    private func drawWatermark(in rect: CGRect, context: CGContext) {
        let watermarkText = currentWatermark.getText(customText: customWatermarkText)
        let style = currentWatermark.textStyle
        
        guard !watermarkText.isEmpty else { return }
        
        // 创建文字属性
        let fontSize: CGFloat = 16
        let font = UIFont.systemFont(ofSize: fontSize)
        let textColor = UIColor(style.color)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        let attributedString = NSAttributedString(string: watermarkText, attributes: attributes)
        let textSize = attributedString.size()
        
        // 计算水印位置
        var textRect: CGRect
        switch style.position {
        case .topLeading:
            textRect = CGRect(x: rect.minX + 10, y: rect.minY + 10, width: textSize.width, height: textSize.height)
        case .topTrailing:
            textRect = CGRect(x: rect.maxX - textSize.width - 10, y: rect.minY + 10, width: textSize.width, height: textSize.height)
        case .bottomLeading:
            textRect = CGRect(x: rect.minX + 10, y: rect.maxY - textSize.height - 10, width: textSize.width, height: textSize.height)
        case .bottomTrailing:
            textRect = CGRect(x: rect.maxX - textSize.width - 10, y: rect.maxY - textSize.height - 10, width: textSize.width, height: textSize.height)
        case .bottomCenter:
            textRect = CGRect(x: rect.midX - textSize.width / 2, y: rect.maxY - textSize.height - 10, width: textSize.width, height: textSize.height)
        }
        
        // 绘制半透明背景
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        let backgroundRect = textRect.insetBy(dx: -4, dy: -2)
        context.fillEllipse(in: backgroundRect)
        
        // 绘制文字
        attributedString.draw(in: textRect)
    }
    
    // 绘制胶片孔
    private func drawFilmHoles(in rect: CGRect, context: CGContext) {
        context.setFillColor(UIColor.white.cgColor)
        
        let holeWidth: CGFloat = 20
        let holeHeight: CGFloat = 10
        let spacing: CGFloat = 15
        let holeCount = 8
        
        // 顶部胶片孔
        let topY: CGFloat = 10
        for i in 0..<holeCount {
            let x = (rect.width - CGFloat(holeCount) * holeWidth - CGFloat(holeCount - 1) * spacing) / 2 + CGFloat(i) * (holeWidth + spacing)
            let holeRect = CGRect(x: x, y: topY, width: holeWidth, height: holeHeight)
            context.fillEllipse(in: holeRect)
        }
        
        // 底部胶片孔
        let bottomY = rect.height - holeHeight - 10
        for i in 0..<holeCount {
            let x = (rect.width - CGFloat(holeCount) * holeWidth - CGFloat(holeCount - 1) * spacing) / 2 + CGFloat(i) * (holeWidth + spacing)
            let holeRect = CGRect(x: x, y: bottomY, width: holeWidth, height: holeHeight)
            context.fillEllipse(in: holeRect)
        }
    }
}

// MARK: - 工具按钮组件
struct ToolButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .yellow : .white)
            .frame(width: 60)
        }
    }
}

#Preview {
    PhotoEditView(originalImage: UIImage(systemName: "photo") ?? UIImage())
} 