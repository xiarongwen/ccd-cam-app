//
//  CameraPreviewView.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

struct CameraPreviewView: View {
    let session: AVCaptureSession
    @Binding var focusPoint: CGPoint?
    @ObservedObject var cameraService: CameraService
    let onTap: (CGPoint) -> Void
    let onPinch: (CGFloat) -> Void
    
    var body: some View {
        ZStack {
            VStack {
                LensSelector(cameraService: cameraService)
                Spacer()
            }
            // 基础相机预览层
            BasePreviewView(session: session)
                .onTapGesture { location in
                    focusPoint = location
                    let size = UIScreen.main.bounds.size
                    let point = CGPoint(x: location.x / size.width, y: location.y / size.height)
                    onTap(point)
                }
                .gesture(
                    MagnificationGesture()
                        .onChanged { scale in
                            onPinch(scale)
                        }
                )
            
            // 实时滤镜覆盖层
            if let previewImage = cameraService.previewImage, cameraService.currentFilter != .none {
                FilteredImageView(
                    ciImage: previewImage,
                    isUsingFrontCamera: cameraService.isUsingFrontCamera,
                    deviceOrientation: cameraService.deviceOrientation
                )
                .allowsHitTesting(false) // 让手势穿透到下层
            }
            
            // 对焦指示器
            if let point = focusPoint {
                FocusIndicator()
                    .position(point)
            }
        }
    }
}

// MARK: - 基础预览视图
struct BasePreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // 基础预览不需要更新
    }
}

// MARK: - 滤镜预览视图
struct FilteredImageView: UIViewRepresentable {
    let ciImage: CIImage
    let isUsingFrontCamera: Bool
    let deviceOrientation: UIDeviceOrientation
    
    func makeUIView(context: Context) -> FilteredPreviewView {
        return FilteredPreviewView()
    }
    
    func updateUIView(_ uiView: FilteredPreviewView, context: Context) {
        uiView.setCameraPosition(isUsingFrontCamera)
        uiView.setDeviceOrientation(deviceOrientation)
        uiView.updateImage(ciImage)
    }
}

class FilteredPreviewView: UIView {
    private let imageView: UIImageView
    private let context = CIContext()
    private var deviceOrientation: UIDeviceOrientation = .portrait
    private var isUsingFrontCamera: Bool = false
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        super.init(frame: frame)
        setupImageView()
        setupOrientationObservers()
    }
    
    required init?(coder: NSCoder) {
        imageView = UIImageView()
        super.init(coder: coder)
        setupImageView()
        setupOrientationObservers()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupOrientationObservers() {
        // 设置设备方向变化监听
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        // 开始监视设备方向变化
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // 初始化方向
        deviceOrientation = UIDevice.current.orientation
        if !deviceOrientation.isValidInterfaceOrientation {
            deviceOrientation = .portrait
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    @objc private func deviceOrientationDidChange() {
        let newOrientation = UIDevice.current.orientation
        
        // 只接受有效的界面方向
        if newOrientation.isValidInterfaceOrientation {
            let oldOrientation = deviceOrientation
            deviceOrientation = newOrientation
            
            if oldOrientation != deviceOrientation {
                print("📱 设备方向已更新: \(oldOrientation.rawValue) -> \(deviceOrientation.rawValue)")
            }
        }
    }
    
    func setCameraPosition(_ isFront: Bool) {
        self.isUsingFrontCamera = isFront
        print("📷 相机位置已设置为: \(isUsingFrontCamera ? "前置" : "后置")")
    }
    
    func setDeviceOrientation(_ orientation: UIDeviceOrientation) {
        self.deviceOrientation = orientation
        print("📱 设备方向已设置为: \(orientation.rawValue)")
    }
    
    func updateImage(_ ciImage: CIImage) {
        // 在后台线程处理图像
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            // 应用正确的方向
            let orientedImage = self.applyCorrectOrientation(to: ciImage)
            
            // 渲染为UIImage
            if let cgImage = self.context.createCGImage(orientedImage, from: orientedImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async {
                    self.imageView.image = uiImage
                }
            }
        }
    }
    
    private func applyCorrectOrientation(to image: CIImage) -> CIImage {
        var orientedImage = image
        
        // 基于设备方向应用旋转变换
        switch deviceOrientation {
        case .portrait:
            // 不需要旋转，保持原样
            break
            
        case .portraitUpsideDown:
            // 旋转180度
            orientedImage = orientedImage.oriented(.down)
            
        case .landscapeLeft:
            // 旋转90度
            orientedImage = orientedImage.oriented(.right)
            
        case .landscapeRight:
            // 旋转270度
            orientedImage = orientedImage.oriented(.left)
            
        default:
            // 对于其他方向（如平放、面朝上/下），保持当前方向不变
            break
        }
        
        // 如果使用前置相机，需要水平翻转图像
        if isUsingFrontCamera {
            // 对于前置相机，需要水平翻转
            orientedImage = orientedImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        }
        
        print("🔄 应用图像方向修正: 设备方向=\(deviceOrientation.rawValue), 相机=\(isUsingFrontCamera ? "前置" : "后置")")
        
        return orientedImage
    }
}

// MARK: - 对焦指示器
struct FocusIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .stroke(Color.yellow, lineWidth: 2)
            .frame(width: 80, height: 80)
            .scaleEffect(isAnimating ? 0.8 : 1.0)
            .opacity(isAnimating ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isAnimating = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isAnimating = false
                    }
                }
            }
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - 焦段选择器
import AVFoundation

enum CameraLensType: String, CaseIterable, Identifiable {
    case ultraWide = "超广角"
    case wide = "主摄"
    case telephoto = "长焦"
    var id: String { rawValue }
}

struct LensSelector: View {
    @ObservedObject var cameraService: CameraService
    var body: some View {
        HStack(spacing: 16) {
            ForEach(CameraLensType.allCases) { lens in
                Button(action: {
                    cameraService.switchLens(to: lens)
                }) {
                    Text(lens.rawValue)
                        .fontWeight(cameraService.currentLens == lens ? .bold : .regular)
                        .foregroundColor(cameraService.currentLens == lens ? .yellow : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(cameraService.currentLens == lens ? Color.yellow.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                }
                .disabled(!cameraService.isLensAvailable(lens))
                .opacity(cameraService.isLensAvailable(lens) ? 1 : 0.3)
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 8)
    }
} 