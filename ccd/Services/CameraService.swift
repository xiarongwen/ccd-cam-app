//
//  CameraService.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import AVFoundation
import SwiftUI
import CoreImage
import Photos

class CameraService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var session = AVCaptureSession()
    @Published var isSessionRunning = false
    @Published var isAuthorized = false
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var isCapturing = false
    @Published var previewImage: CIImage?
    @Published var currentFilter: FilterType = .none
    @Published var isUsingFrontCamera: Bool = false
    @Published var deviceOrientation: UIDeviceOrientation = .portrait
    @Published var currentLens: CameraLensType = .wide
    
    // MARK: - Session Management
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let videoDataQueue = DispatchQueue(label: "camera.video.queue")
    private var videoDeviceInput: AVCaptureDeviceInput?
    let photoOutput = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var videoDevice: AVCaptureDevice?
    
    // MARK: - Photo Capture
    private var inFlightPhotoCaptureProcessors: [Int64: PhotoCaptureProcessor] = [:]
    
    // MARK: - Filter Processing
    private let context = CIContext()
    private var lastProcessTime: CFTimeInterval = 0
    private let processInterval: CFTimeInterval = 1.0/15.0 // 15 FPS
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupOrientationMonitoring()
        checkPermissions()
    }
    
    // MARK: - Permission Handling
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }
    
    // MARK: - Session Configuration
    func setupSession() {
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }
    
    private func configureSession() {
        print("🔧 开始配置相机会话...")
        session.beginConfiguration()
        session.sessionPreset = .photo
        print("🔧 设置会话预设为 .photo")
        
        // Add video input
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
                print("🔧 使用双摄像头")
                isUsingFrontCamera = false
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
                print("🔧 使用后置广角摄像头")
                isUsingFrontCamera = false
            }
            
            guard let videoDevice = defaultVideoDevice else {
                print("🔧 错误：无法获取默认视频设备")
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                self.videoDevice = videoDevice
                print("🔧 成功添加视频输入")
            } else {
                print("🔧 错误：无法添加视频输入到会话")
                session.commitConfiguration()
                return
            }
        } catch {
            print("🔧 错误：创建视频输入失败: \(error)")
            session.commitConfiguration()
            return
        }
        
        // Add photo output
        print("🔧 尝试添加照片输出...")

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
            print("🔧 成功添加照片输出")
            print("🔧 photoOutput.isHighResolutionCaptureEnabled: \(photoOutput.isHighResolutionCaptureEnabled)")
            print("🔧 photoOutput.maxPhotoQualityPrioritization: \(photoOutput.maxPhotoQualityPrioritization.rawValue)")
        } else {
            print("🔧 错误：无法添加照片输出到会话")
            session.commitConfiguration()
            return
        }
        
        // Add video data output for real-time processing
        print("🔧 尝试添加视频数据输出...")
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataQueue)
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            if let connection = videoDataOutput.connection(with: .video) {
                connection.isEnabled = true
                
                // 设置初始视频方向
                if connection.isVideoOrientationSupported {
                    let videoOrientation = convertDeviceOrientationToVideoOrientation(deviceOrientation)
                    connection.videoOrientation = videoOrientation
                    print("🔧 设置视频输出方向为: \(videoOrientation.rawValue)")
                }
                
                // 设置视频稳定模式
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
                
                print("🔧 成功配置视频数据输出连接")
            }
            print("🔧 成功添加视频数据输出")
        } else {
            print("🔧 警告：无法添加视频数据输出")
        }
        
        session.commitConfiguration()
        print("🔧 会话配置完成")
        print("🔧 会话输入数量: \(session.inputs.count)")
        print("🔧 会话输出数量: \(session.outputs.count)")
    }
    
    // MARK: - Session Control
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
    }
    
    // MARK: - Filter Control
    func updateFilter(_ filter: FilterType) {
        currentFilter = filter
    }
    
    // MARK: - Camera Control
    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let currentVideoDevice = self.videoDeviceInput?.device else { return }
            let currentPosition = currentVideoDevice.position
            let preferredPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
            
            let devices = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                mediaType: .video,
                position: .unspecified
            ).devices
            
            guard let newVideoDevice = devices.first(where: { $0.position == preferredPosition }) else { return }
            
            do {
                let newVideoDeviceInput = try AVCaptureDeviceInput(device: newVideoDevice)
                
                self.session.beginConfiguration()
                
                if let currentInput = self.videoDeviceInput {
                    self.session.removeInput(currentInput)
                }
                
                if self.session.canAddInput(newVideoDeviceInput) {
                    self.session.addInput(newVideoDeviceInput)
                    self.videoDeviceInput = newVideoDeviceInput
                    self.videoDevice = newVideoDevice
                    
                    // 更新前置/后置相机状态
                    DispatchQueue.main.async {
                        self.isUsingFrontCamera = (newVideoDevice.position == .front)
                    }
                }
                
                self.session.commitConfiguration()
            } catch {
                print("Error switching cameras: \(error)")
            }
        }
    }
    
    // MARK: - Focus & Exposure
    func focus(at point: CGPoint) {
        guard let device = videoDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose) {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Could not lock device for configuration: \(error)")
        }
    }
    
    // MARK: - Zoom
    func zoom(factor: CGFloat) {
        guard let device = videoDevice else { return }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
            currentZoomFactor = device.videoZoomFactor
        } catch {
            print("Could not lock device for zoom: \(error)")
        }
    }
    
    // MARK: - Flash
    func toggleFlash() {
        switch flashMode {
        case .off:
            flashMode = .on
        case .on:
            flashMode = .auto
        case .auto:
            flashMode = .off
        @unknown default:
            flashMode = .off
        }
    }
    
    // MARK: - Photo Capture
    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        print("🔵 CameraService.capturePhoto 开始")
        
        guard !isCapturing else {
            print("🔵 错误：正在拍照中")
            return
        }
        
        print("🔵 检查 photoOutput 状态...")
        print("🔵 photoOutput.connections.count: \(photoOutput.connections.count)")
        print("🔵 session.outputs.count: \(session.outputs.count)")
        print("🔵 session.isRunning: \(session.isRunning)")
        
        isCapturing = true
        print("🔵 设置 isCapturing = true")
        
        sessionQueue.async { [weak self] in
            guard let self = self else { 
                print("🔵 错误：self 为 nil")
                return 
            }
            
            print("🔵 在 sessionQueue 中执行...")
            
            let photoSettings = AVCapturePhotoSettings()
            
            // 检查设备兼容性
            if self.photoOutput.isHighResolutionCaptureEnabled {
                photoSettings.isHighResolutionPhotoEnabled = true
                print("🔵 启用高分辨率拍照")
            } else {
                print("🔵 设备不支持高分辨率拍照")
            }
            
            // 检查闪光灯支持
            if self.photoOutput.supportedFlashModes.contains(self.flashMode) {
                photoSettings.flashMode = self.flashMode
                print("🔵 设置闪光灯模式: \(self.flashMode)")
            } else {
                photoSettings.flashMode = .off
                print("🔵 设备不支持当前闪光灯模式，设为关闭")
            }
            
            print("🔵 创建 photoSettings 完成")
            print("🔵 photoSettings.uniqueID: \(photoSettings.uniqueID)")
            print("🔵 photoOutput.supportedFlashModes: \(self.photoOutput.supportedFlashModes)")
            print("🔵 photoOutput.availablePhotoCodecTypes: \(self.photoOutput.availablePhotoCodecTypes)")
            
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                // 根据当前设备方向设置视频方向
                let videoOrientation = self.convertDeviceOrientationToVideoOrientation(self.deviceOrientation)
                photoOutputConnection.videoOrientation = videoOrientation
                print("🔵 设置照片输出视频方向为: \(videoOrientation.rawValue), 设备方向: \(self.deviceOrientation.rawValue)")
                
                // 确保不翻转前置摄像头图像
                photoOutputConnection.isVideoMirrored = self.videoDeviceInput?.device.position == .front
                print("🔵 镜像设置: \(photoOutputConnection.isVideoMirrored)")
            } else {
                print("🔵 警告：没有找到 video 连接")
            }
            
            print("🔵 创建 PhotoCaptureProcessor...")
            let photoCaptureProcessor = PhotoCaptureProcessor(
                uniqueID: photoSettings.uniqueID,
                currentFilter: self.currentFilter,
                completion: { [weak self] result in
                    print("🔵 PhotoCaptureProcessor 回调被调用")
                    DispatchQueue.main.async {
                        print("🔵 在主线程中处理结果...")
                        self?.isCapturing = false
                        
                        // 从字典中移除已完成的processor
                        self?.inFlightPhotoCaptureProcessors.removeValue(forKey: photoSettings.uniqueID)
                        print("🔵 已清理 PhotoCaptureProcessor，剩余数量: \(self?.inFlightPhotoCaptureProcessors.count ?? 0)")
                        
                        completion(result)
                    }
                }
            )
            
            // 将processor添加到字典中以持有引用
            self.inFlightPhotoCaptureProcessors[photoSettings.uniqueID] = photoCaptureProcessor
            print("🔵 已保存 PhotoCaptureProcessor 到字典，当前数量: \(self.inFlightPhotoCaptureProcessors.count)")
            
            print("🔵 调用 photoOutput.capturePhoto...")
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
            print("🔵 photoOutput.capturePhoto 调用完成")
        }
    }
    
    // 设置设备方向监听
    private func setupOrientationMonitoring() {
        // 开始监视设备方向变化
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // 添加设备方向变化通知观察者
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
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
        
        // 只处理有效的界面方向
        if newOrientation.isValidInterfaceOrientation {
            DispatchQueue.main.async {
                self.deviceOrientation = newOrientation
            }
            
            // 更新视频连接的方向
            updateVideoConnectionOrientation()
        }
    }
    
    // 更新视频连接的方向设置
    private func updateVideoConnectionOrientation() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let videoConnection = self.videoDataOutput.connection(with: .video) {
                let videoOrientation = self.convertDeviceOrientationToVideoOrientation(self.deviceOrientation)
                if videoConnection.isVideoOrientationSupported {
                    videoConnection.videoOrientation = videoOrientation
                }
            }
        }
    }
    
    // 将设备方向转换为视频方向
    private func convertDeviceOrientationToVideoOrientation(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch deviceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    
    func switchLens(to lens: CameraLensType) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            let position = self.isUsingFrontCamera ? AVCaptureDevice.Position.front : .back
            let deviceType: AVCaptureDevice.DeviceType
            switch lens {
            case .ultraWide:
                deviceType = .builtInUltraWideCamera
            case .wide:
                deviceType = .builtInWideAngleCamera
            case .telephoto:
                deviceType = .builtInTelephotoCamera
            }
            guard let device = AVCaptureDevice.default(deviceType, for: .video, position: position) else { return }
            do {
                let input = try AVCaptureDeviceInput(device: device)
                self.session.beginConfiguration()
                if let currentInput = self.videoDeviceInput {
                    self.session.removeInput(currentInput)
                }
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.videoDeviceInput = input
                    self.videoDevice = device
                    DispatchQueue.main.async {
                        self.currentLens = lens
                    }
                }
                self.session.commitConfiguration()
            } catch {
                print("切换焦段失败: \(error)")
            }
        }
    }
    
    func isLensAvailable(_ lens: CameraLensType) -> Bool {
        let position = isUsingFrontCamera ? AVCaptureDevice.Position.front : .back
        let deviceType: AVCaptureDevice.DeviceType
        switch lens {
        case .ultraWide:
            deviceType = .builtInUltraWideCamera
        case .wide:
            deviceType = .builtInWideAngleCamera
        case .telephoto:
            deviceType = .builtInTelephotoCamera
        }
        return AVCaptureDevice.default(deviceType, for: .video, position: position) != nil
    }
}

// MARK: - Video Data Output Delegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // 节流处理：限制处理频率到15FPS
        let currentTime = CACurrentMediaTime()
        if currentTime - lastProcessTime < processInterval {
            return
        }
        lastProcessTime = currentTime
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Apply filter if not none
        let filteredImage: CIImage
        if currentFilter != .none {
            filteredImage = FilterEngine.shared.applyFilterToCIImage(ciImage, filterType: currentFilter) ?? ciImage
        } else {
            filteredImage = ciImage
        }
        
        // Update preview on main thread
        DispatchQueue.main.async { [weak self] in
            self?.previewImage = filteredImage
        }
    }
}

// MARK: - Photo Capture Processor
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    private let uniqueID: Int64
    private let currentFilter: FilterType
    private let completion: (Result<UIImage, Error>) -> Void
    
    init(uniqueID: Int64, currentFilter: FilterType, completion: @escaping (Result<UIImage, Error>) -> Void) {
        self.uniqueID = uniqueID
        self.currentFilter = currentFilter
        self.completion = completion
        super.init()
        print("🟢 PhotoCaptureProcessor 初始化完成，uniqueID: \(uniqueID)")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("🟢 photoOutput didFinishProcessingPhoto 被调用，uniqueID: \(uniqueID)")
        
        if let error = error {
            print("🟢 拍照错误: \(error)")
            completion(.failure(error))
            return
        }
        
        print("🟢 开始处理照片数据...")
        print("🟢 photo.isRawPhoto: \(photo.isRawPhoto)")
        print("🟢 photo.resolvedSettings: \(photo.resolvedSettings)")
        
        guard let data = photo.fileDataRepresentation() else {
            print("🟢 错误：无法获取照片数据")
            completion(.failure(CameraError.processingFailed))
            return
        }
        
        print("🟢 照片数据大小: \(data.count) bytes")
        
        guard let originalImage = UIImage(data: data) else {
            print("🟢 错误：无法从数据创建 UIImage")
            completion(.failure(CameraError.processingFailed))
            return
        }
        
        print("🟢 成功创建 UIImage，大小: \(originalImage.size)，方向: \(originalImage.imageOrientation.rawValue)")
        
        // 首先修正图像方向
        let correctedImage = fixOrientation(originalImage)
        print("🟢 已修正图像方向: \(correctedImage.imageOrientation.rawValue)")
        
        // 然后应用滤镜
        let finalImage: UIImage
        if currentFilter != .none {
            print("🟢 应用滤镜: \(currentFilter)")
            if let filteredImage = FilterEngine.shared.applyFilter(to: correctedImage, filterType: currentFilter) {
                finalImage = filteredImage
            } else {
                finalImage = correctedImage
            }
        } else {
            finalImage = correctedImage
        }
        
        print("🟢 处理完成，最终图像大小: \(finalImage.size)")
        completion(.success(finalImage))
    }
    
    // 修正图像方向的辅助函数
    private func fixOrientation(_ image: UIImage) -> UIImage {
        // 如果方向已经是向上的，直接返回
        if image.imageOrientation == .up {
            return image
        }
        
        // 创建一个CGContext并绘制修正方向后的图像
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("🟢 willBeginCaptureFor 被调用，uniqueID: \(uniqueID)")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("🟢 willCapturePhotoFor 被调用，uniqueID: \(uniqueID)")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("🟢 didCapturePhotoFor 被调用，uniqueID: \(uniqueID)")
    }
}

// MARK: - Camera Error
enum CameraError: LocalizedError {
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .processingFailed:
            return "Failed to process the captured photo"
        }
    }
} 
