//
//  FilterIntensityView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

struct FilterIntensityView: View {
    @Binding var filterType: FilterType
    @Binding var intensity: Double
    let previewImage: UIImage?
    @Binding var isPresented: Bool
    
    @State private var tempIntensity: Double = 1.0
    @State private var previewProcessedImage: UIImage?
    @State private var isProcessingPreview = false
    @State private var previewUpdateTask: DispatchWorkItem?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    applyChanges()
                }
            
            VStack(spacing: 0) {
                // 顶部控制栏
                topControlBar
                
                // 预览区域
                previewArea
                
                // 强度调节区域
                intensityControlArea
                
                // 底部操作栏
                bottomActionBar
            }
        }
        .onAppear {
            tempIntensity = intensity
            updatePreview()
        }
        .onDisappear {
            // 清理未完成的任务
            previewUpdateTask?.cancel()
        }
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack {
            Button("取消") {
                cancelChanges()
            }
            .foregroundColor(.white)
            
            Spacer()
            
            VStack {
                Text("滤镜强度")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(filterType.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button("确定") {
                applyChanges()
            }
            .foregroundColor(.yellow)
            .fontWeight(.semibold)
        }
        .padding()
    }
    
    // MARK: - 预览区域
    private var previewArea: some View {
        ZStack {
            if let processedImage = previewProcessedImage {
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else if let originalImage = previewImage {
                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("暂无预览")
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            // 处理指示器
            if isProcessingPreview {
                Color.black.opacity(0.3)
                    .cornerRadius(12)
                
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
            }
            
            // 强度显示
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(Int(tempIntensity * 100))%")
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    // MARK: - 强度调节区域
    private var intensityControlArea: some View {
        VStack(spacing: 20) {
            // 标题
            HStack {
                Text("滤镜强度")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(tempIntensity * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .frame(width: 60, alignment: .trailing)
            }
            
            // 滑杆
            HStack(spacing: 16) {
                // 最小值标识
                VStack {
                    Image(systemName: "circle")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("0%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                // 滑杆
                CustomSlider(
                    value: $tempIntensity,
                    range: 0...1,
                    onEditingChanged: { _ in
                        updatePreviewWithDelay()
                    }
                )
                
                // 最大值标识
                VStack {
                    Image(systemName: "circle.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text("100%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            // 预设强度按钮
            HStack(spacing: 12) {
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { preset in
                    PresetIntensityButton(
                        value: preset,
                        isSelected: abs(tempIntensity - preset) < 0.05,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                tempIntensity = preset
                            }
                            updatePreviewWithDelay()
                            
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - 底部操作栏
    private var bottomActionBar: some View {
        HStack(spacing: 20) {
            // 重置按钮
            Button(action: resetToDefault) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("重置")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
            }
            
            // 应用按钮
            Button(action: applyChanges) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("应用")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - 方法
    private func updatePreview() {
        guard let originalImage = previewImage else { return }
        
        isProcessingPreview = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let processedImage = self.applyFilterWithIntensity(to: originalImage)
            
            DispatchQueue.main.async {
                self.previewProcessedImage = processedImage
                self.isProcessingPreview = false
            }
        }
    }
    
    private func updatePreviewWithDelay() {
        // 取消之前的任务
        previewUpdateTask?.cancel()
        
        // 创建新的延迟任务
        let task = DispatchWorkItem { [self] in
            updatePreview()
        }
        previewUpdateTask = task
        
        // 延迟执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }
    
    private func applyFilterWithIntensity(to image: UIImage) -> UIImage {
        // 如果强度为0，返回原图
        if tempIntensity <= 0.01 {
            return image
        }
        
        // 如果强度为1，返回完整滤镜效果
        if tempIntensity >= 0.99 {
            return FilterEngine.shared.applyFilter(to: image, filterType: filterType) ?? image
        }
        
        // 应用部分强度的滤镜
        return FilterEngine.shared.applyFilterWithIntensity(
            to: image,
            filterType: filterType,
            intensity: tempIntensity
        ) ?? image
    }
    
    private func resetToDefault() {
        withAnimation(.easeInOut(duration: 0.3)) {
            tempIntensity = 1.0
        }
        updatePreview()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func applyChanges() {
        intensity = tempIntensity
        isPresented = false
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func cancelChanges() {
        // 取消正在进行的预览更新任务
        previewUpdateTask?.cancel()
        isPresented = false
    }
}

// MARK: - 自定义滑杆
struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let onEditingChanged: (Bool) -> Void
    
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景轨道
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                // 活跃轨道
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: thumbPosition(in: geometry.size.width), height: 6)
                    .cornerRadius(3)
                
                // 滑块
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .scaleEffect(isDragging ? 1.2 : 1.0)
                    .offset(x: thumbPosition(in: geometry.size.width) - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                if !isDragging {
                                    isDragging = true
                                    onEditingChanged(true)
                                    
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                                
                                let newValue = Double(drag.location.x / geometry.size.width)
                                value = min(max(newValue, range.lowerBound), range.upperBound)
                            }
                            .onEnded { _ in
                                isDragging = false
                                onEditingChanged(false)
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            }
                    )
            }
        }
        .frame(height: 24)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
    
    private func thumbPosition(in width: CGFloat) -> CGFloat {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(normalizedValue) * width
    }
}

// MARK: - 预设强度按钮
struct PresetIntensityButton: View {
    let value: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                
                Rectangle()
                    .fill(isSelected ? Color.yellow : Color.gray.opacity(0.5))
                    .frame(width: 30, height: 4)
                    .cornerRadius(2)
            }
            .foregroundColor(isSelected ? .yellow : .gray)
            .frame(width: 50)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    FilterIntensityView(
        filterType: .constant(.ccdClassic),
        intensity: .constant(1.0),
        previewImage: nil,
        isPresented: .constant(true)
    )
} 