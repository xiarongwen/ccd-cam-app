//
//  PhotoPreviewWithFrame.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

struct PhotoPreviewWithFrame: View {
    let image: UIImage
    let filter: FilterType
    let frame: FrameType
    let watermark: WatermarkType
    let customText: String
    
    var body: some View {
        ZStack {
            // 相框背景
            frameBackground
            
            // 照片内容
            photoContent
                .padding(.top, frame.frameParams.topPadding)
                .padding(.horizontal, frame.frameParams.sidePadding)
                .padding(.bottom, frame.frameParams.bottomPadding)
        }
        .clipShape(RoundedRectangle(cornerRadius: frame.frameParams.cornerRadius))
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - 相框背景
    private var frameBackground: some View {
        Rectangle()
            .fill(frame.frameParams.color)
            .overlay(
                // 胶片孔效果（用于胶片条相框）
                filmHolesOverlay
            )
    }
    
    // MARK: - 照片内容
    private var photoContent: some View {
        ZStack {
            // 照片本身
            Image(uiImage: processedImage)
                .resizable()
                .aspectRatio(3/4, contentMode: .fit)
                .clipped()
            
            // 水印覆盖
            watermarkOverlay
        }
    }
    
    // MARK: - 处理后的图片
    private var processedImage: UIImage {
        if filter != .none {
            return FilterEngine.shared.applyFilter(to: image, filterType: filter) ?? image
        }
        return image
    }
    
    // MARK: - 胶片孔效果
    private var filmHolesOverlay: some View {
        Group {
            if frame == .filmStrip {
                VStack {
                    // 顶部胶片孔
                    HStack(spacing: 15) {
                        ForEach(0..<8) { _ in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 20, height: 10)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // 底部胶片孔
                    HStack(spacing: 15) {
                        ForEach(0..<8) { _ in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 20, height: 10)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
    
    // MARK: - 水印覆盖
    private var watermarkOverlay: some View {
        GeometryReader { geometry in
            if watermark != .none {
                let watermarkText = watermark.getText(customText: customText)
                let style = watermark.textStyle
                
                Text(watermarkText)
                    .font(style.font)
                    .foregroundColor(style.color)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black.opacity(0.5))
                            .blur(radius: 1)
                    )
                    .position(
                        x: getWatermarkX(for: style.position, in: geometry.size),
                        y: getWatermarkY(for: style.position, in: geometry.size)
                    )
            }
        }
    }
    
    // MARK: - 水印位置计算
    private func getWatermarkX(for position: WatermarkPosition, in size: CGSize) -> CGFloat {
        switch position {
        case .topLeading, .bottomLeading:
            return size.width * 0.1
        case .topTrailing, .bottomTrailing:
            return size.width * 0.9
        case .bottomCenter:
            return size.width * 0.5
        }
    }
    
    private func getWatermarkY(for position: WatermarkPosition, in size: CGSize) -> CGFloat {
        switch position {
        case .topLeading, .topTrailing:
            return size.height * 0.1
        case .bottomLeading, .bottomTrailing, .bottomCenter:
            return size.height * 0.9
        }
    }
}

// MARK: - 拍立得底部文字区域扩展
extension PhotoPreviewWithFrame {
    // 对于拍立得相框，可以在底部区域添加手写文字效果
    private var polaroidBottomArea: some View {
        Group {
            if frame == .polaroid || frame == .polaroidVintage {
                VStack {
                    Spacer()
                    
                    // 拍立得底部留白区域
                    Rectangle()
                        .fill(frame.frameParams.color)
                        .frame(height: frame.frameParams.bottomPadding - 40)
                        .overlay(
                            // 可以添加手写文字或日期
                            VStack {
                                if watermark == .ccdBrand {
                                    Text("CCD CAMERA")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.gray)
                                        .padding(.top, 20)
                                }
                                
                                Spacer()
                                
                                // 底部小字
                                Text(getCurrentDate())
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 10)
                            }
                        )
                }
            }
        }
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }
}

#Preview {
    PhotoPreviewWithFrame(
        image: UIImage(systemName: "photo") ?? UIImage(),
        filter: .ccdClassic,
        frame: .polaroid,
        watermark: .timestamp,
        customText: ""
    )
    .frame(width: 300, height: 400)
} 