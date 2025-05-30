//
//  GalleryView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI
import Photos

struct GalleryView: View {
    @State private var photos: [PHAsset] = []
    @State private var selectedPhoto: PHAsset?
    @State private var showFullScreen = false
    @State private var currentFilterCategory: FilterType = .none
    @State private var isLoading = true
    @State private var showingDeleteAlert = false
    @State private var photoToDelete: PHAsset?
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
                } else if photos.isEmpty {
                    emptyGalleryView
                } else {
                    galleryContentView
                }
            }
            .navigationTitle("相册")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterMenu
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadPhotos()
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            if let photo = selectedPhoto {
                PhotoDetailView(asset: photo, photos: photos)
            }
        }
        .alert("删除照片", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let photo = photoToDelete {
                    deletePhoto(photo)
                }
            }
        } message: {
            Text("确定要删除这张照片吗？此操作无法撤销。")
        }
    }
    
    // MARK: - 加载视图
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("正在加载相册...")
                .foregroundColor(.white)
                .font(.headline)
        }
    }
    
    // MARK: - 空相册视图
    private var emptyGalleryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("还没有照片")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("使用CCD相机拍摄你的第一张复古照片吧")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("开始拍摄") {
                dismiss()
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.yellow)
            .foregroundColor(.black)
            .font(.headline)
            .cornerRadius(8)
        }
    }
    
    // MARK: - 相册内容视图
    private var galleryContentView: some View {
        VStack(spacing: 0) {
            // 统计信息
            HStack {
                Text("\(photos.count) 张照片")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Spacer()
                
                if currentFilterCategory != .none {
                    Text("滤镜: \(currentFilterCategory.displayName)")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // 照片网格
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(photos, id: \.self) { photo in
                        PhotoThumbnail(
                            asset: photo,
                            onTap: {
                                selectedPhoto = photo
                                showFullScreen = true
                            },
                            onLongPress: {
                                photoToDelete = photo
                                showingDeleteAlert = true
                            }
                        )
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - 滤镜菜单
    private var filterMenu: some View {
        Menu {
            Button {
                currentFilterCategory = .none
                loadPhotos()
            } label: {
                HStack {
                    Text("全部照片")
                    if currentFilterCategory == .none {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Divider()
            
            ForEach([FilterType.ccdClassic, .fuji400H, .vintage90s, .leica], id: \.self) { filter in
                Button {
                    currentFilterCategory = filter
                    loadPhotos(filterBy: filter)
                } label: {
                    HStack {
                        Text(filter.displayName)
                        if currentFilterCategory == filter {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.horizontal.3.decrease.circle")
                .foregroundColor(.white)
                .font(.title3)
        }
    }
    
    // MARK: - 方法
    private func loadPhotos(filterBy filter: FilterType? = nil) {
        isLoading = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var photoArray: [PHAsset] = []
        
        assets.enumerateObjects { asset, _, _ in
            photoArray.append(asset)
        }
        
        // 如果指定了滤镜，这里可以根据照片的元数据进行过滤
        // 暂时显示所有照片
        
        DispatchQueue.main.async {
            self.photos = photoArray
            self.isLoading = false
        }
    }
    
    private func deletePhoto(_ asset: PHAsset) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    loadPhotos()
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                } else {
                    print("删除失败: \(error?.localizedDescription ?? "未知错误")")
                }
            }
        }
    }
}

// MARK: - 照片缩略图组件
struct PhotoThumbnail: View {
    let asset: PHAsset
    let onTap: () -> Void
    let onLongPress: () -> Void
    @State private var image: UIImage?
    @State private var isLoading = true
    
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
            
            // 照片类型标识
            VStack {
                HStack {
                    Spacer()
                    if asset.mediaSubtypes.contains(.photoHDR) {
                        Text("HDR")
                            .font(.caption2)
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                Spacer()
            }
            .padding(4)
        }
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture {
            onLongPress()
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
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
                self.isLoading = false
            }
        }
    }
}

// MARK: - 照片详情视图
struct PhotoDetailView: View {
    let asset: PHAsset
    let photos: [PHAsset]
    @State private var currentIndex: Int = 0
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var showingEditView = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // 顶部导航
                HStack {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(currentIndex + 1) / \(photos.count)")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("编辑") {
                        if let image = image {
                            showingEditView = true
                        }
                    }
                    .foregroundColor(.yellow)
                }
                .padding()
                
                // 照片显示区域
                TabView(selection: $currentIndex) {
                    ForEach(0..<photos.count, id: \.self) { index in
                        PhotoDetailCard(asset: photos[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear {
                    currentIndex = photos.firstIndex(of: asset) ?? 0
                }
                
                // 照片信息
                if let asset = photos.indices.contains(currentIndex) ? photos[currentIndex] : nil {
                    PhotoInfoView(asset: asset)
                        .padding()
                }
            }
        }
        .fullScreenCover(isPresented: $showingEditView) {
            if let image = image {
                PhotoEditView(originalImage: image)
            }
        }
    }
}

// MARK: - 照片详情卡片
struct PhotoDetailCard: View {
    let asset: PHAsset
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .onAppear {
            loadFullImage()
        }
    }
    
    private func loadFullImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

// MARK: - 照片信息视图
struct PhotoInfoView: View {
    let asset: PHAsset
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("拍摄时间")
                    .foregroundColor(.gray)
                Spacer()
                Text(formatDate(asset.creationDate))
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("尺寸")
                    .foregroundColor(.gray)
                Spacer()
                Text("\(asset.pixelWidth) × \(asset.pixelHeight)")
                    .foregroundColor(.white)
            }
            
            if let location = asset.location {
                HStack {
                    Text("位置")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(location.coordinate.latitude, specifier: "%.4f"), \(location.coordinate.longitude, specifier: "%.4f")")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "未知" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

#Preview {
    GalleryView()
} 