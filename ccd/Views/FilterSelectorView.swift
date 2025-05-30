//
//  FilterSelectorView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI
import UIKit

struct FilterSelectorView: View {
    @Binding var selectedFilter: FilterType
    @Binding var isPresented: Bool
    let previewImage: CIImage?
    @State private var selectedCategory: FilterCategory = .ccd
    @State private var showIntensityAdjustment = false
    @State private var filterIntensity: Double = 1.0
    
    enum FilterCategory: String, CaseIterable {
        case ccd = "CCD"
        case film = "胶片"
        case vintage = "复古"
        
        var filters: [FilterType] {
            switch self {
            case .ccd:
                return [.none, .ccdClassic, .ccdWarm, .ccdCool, .ccdNight]
            case .film:
                return [.fuji400H, .kodakGold200, .agfaVista, .ilfordHP5, .leica]
            case .vintage:
                return [.vintage90s, .retrowave, .lofi]
            }
        }
    }
    
    var body: some View {
        mainContent
            .background(backgroundView)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
            .onAppear {
                print("FilterSelectorView 已显示")
            }
            .onDisappear {
                print("FilterSelectorView 已隐藏")
            }
            .overlay(intensityAdjustmentOverlay)
    }
    
    // MARK: - 主要内容
    private var mainContent: some View {
        VStack(spacing: 0) {
            dragHandle
            titleSection
            categorySelector
            filterGrid
        }
    }
    
    // MARK: - 拖动手柄
    private var dragHandle: some View {
        Capsule()
            .fill(Color(white: 0.5))
            .frame(width: 40, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 20)
    }
    
    // MARK: - 标题区域
    private var titleSection: some View {
        HStack {
            Text("滤镜选择")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            intensityButton
            closeButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - 强度调节按钮
    @ViewBuilder
    private var intensityButton: some View {
        if selectedFilter != .none && selectedFilter != FilterType.none {
            Button(action: {
                print("🎛️ 打开强度调节面板，当前滤镜: \(selectedFilter.displayName)")
                showIntensityAdjustment = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16))
                    Text("强度")
                        .font(.system(size: 14))
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.2))
                )
            }
        }
    }
    
    // MARK: - 关闭按钮
    private var closeButton: some View {
        Button(action: {
            print("关闭滤镜选择器")
            withAnimation(.spring()) {
                isPresented = false
            }
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(white: 0.5))
        }
    }
    
    // MARK: - 分类选择器
    private var categorySelector: some View {
        HStack(spacing: 0) {
            ForEach(FilterCategory.allCases, id: \.self) { category in
                CategoryTab(
                    title: category.rawValue,
                    isSelected: selectedCategory == category,
                    action: {
                        print("选择分类: \(category.rawValue)")
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - 滤镜网格
    private var filterGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ],
                spacing: 15
            ) {
                ForEach(selectedCategory.filters, id: \.self) { filter in
                    FilterCard(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        action: {
                            handleFilterSelection(filter)
                        },
                        previewImage: previewImage
                    )
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - 背景视图
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
            .ignoresSafeArea()
    }
    
    // MARK: - 强度调节覆盖层
    @ViewBuilder
    private var intensityAdjustmentOverlay: some View {
        if showIntensityAdjustment {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showIntensityAdjustment = false
                }
            
            VStack {
                Spacer()
                if selectedFilter != .none {
                    FilterIntensityView(
                        filterType: $selectedFilter,
                        intensity: $filterIntensity,
                        previewImage: convertCIImageToUIImage(previewImage),
                        isPresented: $showIntensityAdjustment
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // 如果没有选择滤镜，显示提示信息
                    VStack {
                        Text("请先选择一个滤镜")
                            .foregroundColor(.white)
                            .padding()
                        
                        Button("关闭") {
                            showIntensityAdjustment = false
                        }
                        .foregroundColor(.yellow)
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.8))
                    )
                    .padding()
                }
            }
        }
    }
    
    // MARK: - 图像转换辅助方法
    private func convertCIImageToUIImage(_ ciImage: CIImage?) -> UIImage? {
        guard let ciImage = ciImage else { 
            print("⚠️ CIImage 为空，返回 nil")
            return nil 
        }
        
        do {
            let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
            
            // 限制图像大小以避免内存问题
            let maxDimension: CGFloat = 1024
            let extent = ciImage.extent
            let scale = min(maxDimension / extent.width, maxDimension / extent.height, 1.0)
            
            let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            let scaledExtent = scaledImage.extent
            
            guard let cgImage = context.createCGImage(scaledImage, from: scaledExtent) else {
                print("⚠️ 无法创建 CGImage")
                return nil
            }
            
            let uiImage = UIImage(cgImage: cgImage)
            print("✅ 成功转换图像，大小: \(uiImage.size)")
            return uiImage
            
        } catch {
            print("❌ 图像转换失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 滤镜选择处理
    private func handleFilterSelection(_ filter: FilterType) {
        print("🎨 选择滤镜: \(filter.displayName)")
        
        // 确保在主线程上更新UI
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.selectedFilter = filter
            }
            
            // 重置强度调节面板状态
            if self.showIntensityAdjustment {
                self.showIntensityAdjustment = false
            }
            
            // 震动反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // 自动关闭
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring()) {
                    self.isPresented = false
                }
            }
        }
    }
}

// MARK: - 分类标签
struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color(white: 0.6))
                // 下划线指示器
                Rectangle()
                    .fill(isSelected ? Color.yellow : Color.clear)
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - 滤镜卡片（上图下字实时预览）
struct FilterCard: View {
    let filter: FilterType
    let isSelected: Bool
    let action: () -> Void
    let previewImage: CIImage?
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                    Image(systemName: getFilterIcon(for: filter))
                        .font(.system(size: 32))
                        .foregroundColor(isSelected ? .yellow : Color(white: 0.7))
                }
                .aspectRatio(1, contentMode: .fit)
                Text(filter.displayName)
                    .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .yellow : .white)
                    .lineLimit(1)
            }
            .padding(6)
            .background(isSelected ? Color.yellow.opacity(0.08) : Color.clear)
            .cornerRadius(12)
            .shadow(color: isSelected ? Color.yellow.opacity(0.2) : .clear, radius: 6)
        }
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func getFilterIcon(for filter: FilterType) -> String {
        switch filter {
        case .none:
            return "circle"
        case .ccdClassic, .ccdWarm, .ccdCool, .ccdNight:
            return "camera.fill"
        case .fuji400H, .kodakGold200, .agfaVista, .ilfordHP5:
            return "film"
        case .leica:
            return "camera.aperture"
        case .vintage90s, .retrowave, .lofi:
            return "sparkles"
        }
    }
}

// MARK: - 实时滤镜缩略图
struct FilteredPreviewThumbnail: UIViewRepresentable {
    let ciImage: CIImage
    let filter: FilterType
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        DispatchQueue.global(qos: .userInitiated).async {
            let filtered: CIImage
            if filter == .none {
                filtered = ciImage
            } else {
                filtered = FilterEngine.shared.applyFilterToCIImage(ciImage, filterType: filter) ?? ciImage
            }
            let context = CIContext()
            if let cgImage = context.createCGImage(filtered, from: filtered.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    uiView.image = uiImage
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FilterSelectorView(
            selectedFilter: .constant(.ccdClassic),
            isPresented: .constant(true),
            previewImage: nil
        )
    }
} 