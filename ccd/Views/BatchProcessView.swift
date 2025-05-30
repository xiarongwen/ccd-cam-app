//
//  BatchProcessView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI
import Photos

struct BatchProcessView: View {
    @State private var selectedPhotos: Set<PHAsset> = []
    @State private var allPhotos: [PHAsset] = []
    @State private var isLoading = true
    @State private var isProcessing = false
    @State private var currentFilter: FilterType = .ccdClassic
    @State private var currentFrame: FrameType = .polaroid
    @State private var currentWatermark: WatermarkType = .timestamp
    @State private var customWatermarkText: String = ""
    @State private var processingProgress: Double = 0.0
    @State private var processedCount: Int = 0
    @State private var showingCompleteAlert = false
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else {
                    VStack(spacing: 0) {
                        // 顶部控制栏
                        topControlBar
                        
                        // 效果设置区域
                        if !selectedPhotos.isEmpty {
                            effectSettingsSection
                        }
                        
                        // 照片选择区域
                        photoSelectionArea
                        
                        // 底部操作栏
                        bottomActionBar
                    }
                }
                
                // 处理进度覆盖层
                if isProcessing {
                    processingOverlay
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadPhotos()
        }
        .alert("批量处理完成", isPresented: $showingCompleteAlert) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("成功处理了 \(processedCount) 张照片")
        }
    }
    
    // MARK: - 加载视图
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("正在加载照片...")
                .foregroundColor(.white)
                .font(.headline)
        }
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack {
            Button("取消") {
                dismiss()
            }
            .foregroundColor(.white)
            
            Spacer()
            
            VStack {
                Text("批量处理")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if !selectedPhotos.isEmpty {
                    Text("已选择 \(selectedPhotos.count) 张")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            Button(selectedPhotos.isEmpty ? "全选" : "清空") {
                if selectedPhotos.isEmpty {
                    selectAllPhotos()
                } else {
                    clearSelection()
                }
            }
            .foregroundColor(.yellow)
        }
        .padding()
    }
    
    // MARK: - 效果设置区域
    private var effectSettingsSection: some View {
        VStack(spacing: 16) {
            Text("效果设置")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // 滤镜选择
                    EffectSelector(
                        title: "滤镜",
                        value: currentFilter.displayName,
                        icon: "camera.filters"
                    ) {
                        // 显示滤镜选择器
                    }
                    
                    // 相框选择
                    EffectSelector(
                        title: "相框",
                        value: currentFrame.displayName,
                        icon: "rectangle.portrait"
                    ) {
                        // 显示相框选择器
                    }
                    
                    // 水印选择
                    EffectSelector(
                        title: "水印",
                        value: currentWatermark.displayName,
                        icon: "textformat"
                    ) {
                        // 显示水印选择器
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    // MARK: - 照片选择区域
    private var photoSelectionArea: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(allPhotos, id: \.self) { photo in
                    BatchPhotoThumbnail(
                        asset: photo,
                        isSelected: selectedPhotos.contains(photo),
                        onToggle: {
                            togglePhotoSelection(photo)
                        }
                    )
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - 底部操作栏
    private var bottomActionBar: some View {
        VStack(spacing: 12) {
            if !selectedPhotos.isEmpty {
                // 预览区域
                HStack {
                    Text("预览效果")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Spacer()
                    
                    if let firstPhoto = selectedPhotos.first {
                        BatchPreviewThumbnail(
                            asset: firstPhoto,
                            filter: currentFilter,
                            frame: currentFrame,
                            watermark: currentWatermark,
                            customText: customWatermarkText
                        )
                        .frame(width: 60, height: 75)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            
            // 开始处理按钮
            Button(action: startBatchProcessing) {
                HStack {
                    Image(systemName: "wand.and.rays")
                    Text("开始批量处理 (\(selectedPhotos.count))")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedPhotos.isEmpty ? Color.gray : Color.yellow)
                .cornerRadius(12)
            }
            .disabled(selectedPhotos.isEmpty || isProcessing)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    // MARK: - 处理进度覆盖层
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("正在处理照片...")
                    .font(.title2)
                    .foregroundColor(.white)
                
                ProgressView(value: processingProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    .frame(width: 200)
                
                Text("\(processedCount) / \(selectedPhotos.count)")
                    .foregroundColor(.gray)
                
                Button("取消") {
                    cancelProcessing()
                }
                .foregroundColor(.red)
                .padding(.top)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.1))
            )
        }
    }
    
    // MARK: - 方法
    private func loadPhotos() {
        isLoading = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var photoArray: [PHAsset] = []
        
        assets.enumerateObjects { asset, _, _ in
            photoArray.append(asset)
        }
        
        DispatchQueue.main.async {
            self.allPhotos = photoArray
            self.isLoading = false
        }
    }
    
    private func togglePhotoSelection(_ photo: PHAsset) {
        if selectedPhotos.contains(photo) {
            selectedPhotos.remove(photo)
        } else {
            selectedPhotos.insert(photo)
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func selectAllPhotos() {
        selectedPhotos = Set(allPhotos)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func clearSelection() {
        selectedPhotos.removeAll()
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func startBatchProcessing() {
        guard !selectedPhotos.isEmpty else { return }
        
        isProcessing = true
        processedCount = 0
        processingProgress = 0.0
        
        let photosArray = Array(selectedPhotos)
        let totalCount = photosArray.count
        
        // 开始批量处理
        processBatchPhotos(photosArray, totalCount: totalCount)
    }
    
    private func processBatchPhotos(_ photos: [PHAsset], totalCount: Int) {
        guard !photos.isEmpty else {
            // 处理完成
            isProcessing = false
            showingCompleteAlert = true
            return
        }
        
        let currentPhoto = photos[0]
        let remainingPhotos = Array(photos.dropFirst())
        
        // 处理当前照片
        processPhoto(currentPhoto) { success in
            DispatchQueue.main.async {
                if success {
                    self.processedCount += 1
                }
                
                self.processingProgress = Double(self.processedCount) / Double(totalCount)
                
                // 递归处理剩余照片
                self.processBatchPhotos(remainingPhotos, totalCount: totalCount)
            }
        }
    }
    
    private func processPhoto(_ asset: PHAsset, completion: @escaping (Bool) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        manager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            guard let originalImage = image else {
                completion(false)
                return
            }
            
            // 在后台线程处理图片
            DispatchQueue.global(qos: .userInitiated).async {
                let processedImage = self.createProcessedImage(from: originalImage)
                
                // 保存到相册
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
                }) { success, error in
                    completion(success)
                }
            }
        }
    }
    
    private func createProcessedImage(from originalImage: UIImage) -> UIImage {
        // 应用滤镜
        let filteredImage: UIImage
        if currentFilter != .none {
            filteredImage = FilterEngine.shared.applyFilter(to: originalImage, filterType: currentFilter) ?? originalImage
        } else {
            filteredImage = originalImage
        }
        
        // 创建最终图片（包含相框和水印）
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
    
    private func drawWatermark(in rect: CGRect, context: CGContext) {
        let watermarkText = currentWatermark.getText(customText: customWatermarkText)
        let style = currentWatermark.textStyle
        
        // 根据SwiftUI Font转换为相应的UIFont大小
        let fontSize: CGFloat
        switch style.font {
        case .caption:
            fontSize = 12
        case .caption2:
            fontSize = 11
        case .footnote:
            fontSize = 13
        case .body:
            fontSize = 17
        case .callout:
            fontSize = 16
        default:
            fontSize = 12
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
            .foregroundColor: UIColor(style.color)
        ]
        
        let attributedString = NSAttributedString(string: watermarkText, attributes: attributes)
        let textSize = attributedString.size()
        
        let x: CGFloat
        let y: CGFloat
        
        switch style.position {
        case .bottomLeading:
            x = rect.minX + 10
            y = rect.maxY - textSize.height - 10
        case .bottomTrailing:
            x = rect.maxX - textSize.width - 10
            y = rect.maxY - textSize.height - 10
        case .topLeading:
            x = rect.minX + 10
            y = rect.minY + 10
        case .topTrailing:
            x = rect.maxX - textSize.width - 10
            y = rect.minY + 10
        case .bottomCenter:
            x = rect.midX - textSize.width / 2
            y = rect.maxY - textSize.height - 10
        }
        
        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
        attributedString.draw(in: textRect)
    }
    
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
    
    private func cancelProcessing() {
        isProcessing = false
        processingProgress = 0.0
        processedCount = 0
    }
}

// MARK: - 支持组件

// 效果选择器
struct EffectSelector: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 80)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

// 批量处理照片缩略图
struct BatchPhotoThumbnail: View {
    let asset: PHAsset
    let isSelected: Bool
    let onToggle: () -> Void
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    )
            }
            
            // 选择状态覆盖层
            if isSelected {
                Color.yellow.opacity(0.3)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(4)
            }
        }
        .onTapGesture {
            onToggle()
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        
        let targetSize = CGSize(width: 200, height: 200)
        
        manager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

// 批量处理预览缩略图
struct BatchPreviewThumbnail: View {
    let asset: PHAsset
    let filter: FilterType
    let frame: FrameType
    let watermark: WatermarkType
    let customText: String
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            if let image = image {
                PhotoPreviewWithFrame(
                    image: image,
                    filter: filter,
                    frame: frame,
                    watermark: watermark,
                    customText: customText
                )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        
        let targetSize = CGSize(width: 200, height: 200)
        
        manager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

#Preview {
    BatchProcessView()
} 