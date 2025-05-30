//
//  FilterEngine.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class FilterEngine {
    static let shared = FilterEngine()
    
    private let context: CIContext
    
    private init() {
        // 使用GPU加速
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            context = CIContext(mtlDevice: metalDevice)
        } else {
            context = CIContext()
        }
    }
    
    func applyFilter(to image: UIImage, filterType: FilterType) -> UIImage? {
        return applyFilterWithIntensity(to: image, filterType: filterType, intensity: 1.0)
    }
    
    // 新增：支持强度调节的滤镜应用方法
    func applyFilterWithIntensity(to image: UIImage, filterType: FilterType, intensity: Double) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // 如果强度为0，返回原图
        if intensity <= 0.01 {
            return image
        }
        
        // 如果强度为1，应用完整滤镜
        if intensity >= 0.99 {
            let filteredImage = applyFilterToCIImage(ciImage, filterType: filterType) ?? ciImage
            return renderImage(filteredImage)
        }
        
        // 应用部分强度的滤镜
        guard let filteredCIImage = applyFilterToCIImage(ciImage, filterType: filterType) else {
            return image
        }
        
        // 使用混合模式在原图和滤镜图之间进行插值
        let blendedImage = blendImages(original: ciImage, filtered: filteredCIImage, intensity: intensity)
        return renderImage(blendedImage)
    }
    
    // 混合原图和滤镜图
    private func blendImages(original: CIImage, filtered: CIImage, intensity: Double) -> CIImage {
        guard let blendFilter = CIFilter(name: "CIBlendWithMask") else {
            return filtered
        }
        
        // 创建一个统一强度的蒙版
        let maskImage = CIImage(color: CIColor(red: intensity, green: intensity, blue: intensity, alpha: 1.0))
            .cropped(to: original.extent)
        
        blendFilter.setValue(original, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(filtered, forKey: kCIInputImageKey)
        blendFilter.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        return blendFilter.outputImage ?? filtered
    }
    
    // 新增：直接处理CIImage的方法，用于实时预览
    func applyFilterToCIImage(_ ciImage: CIImage, filterType: FilterType) -> CIImage? {
        switch filterType {
        case .none:
            return ciImage
            
        case .ccdClassic:
            return applyCCDClassic(to: ciImage)
            
        case .ccdWarm:
            return applyCCDWarm(to: ciImage)
            
        case .ccdCool:
            return applyCCDCool(to: ciImage)
            
        case .ccdNight:
            return applyCCDNight(to: ciImage)
            
        case .fuji400H:
            return applyFuji400H(to: ciImage)
            
        case .kodakGold200:
            return applyKodakGold200(to: ciImage)
            
        case .agfaVista:
            return applyAgfaVista(to: ciImage)
            
        case .ilfordHP5:
            return applyIlfordHP5(to: ciImage)
            
        case .leica:
            return applyLeica(to: ciImage)
            
        case .vintage90s:
            return applyVintage90s(to: ciImage)
            
        case .retrowave:
            return applyRetrowave(to: ciImage)
            
        case .lofi:
            return applyLofi(to: ciImage)
        }
    }
    
    private func renderImage(_ ciImage: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - CCD Filters
    
    private func applyCCDClassic(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // 1. 色彩调整 - CCD特有的略微偏暖的色调
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(0.9, forKey: kCIInputSaturationKey) // 降低饱和度
            colorControls.setValue(0.02, forKey: kCIInputBrightnessKey) // 轻微提亮
            colorControls.setValue(1.05, forKey: kCIInputContrastKey) // 轻微增加对比度
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        // 2. 色彩矩阵 - 模拟CCD的色彩偏移
        if let colorMatrix = CIFilter(name: "CIColorMatrix") {
            colorMatrix.setValue(outputImage, forKey: kCIInputImageKey)
            colorMatrix.setValue(CIVector(x: 1.05, y: 0, z: 0, w: 0), forKey: "inputRVector")
            colorMatrix.setValue(CIVector(x: 0, y: 1.08, z: 0, w: 0), forKey: "inputGVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0.95, w: 0), forKey: "inputBVector")
            outputImage = colorMatrix.outputImage ?? outputImage
        }
        
        // 3. 添加轻微的噪点
        outputImage = addDigitalNoise(to: outputImage, intensity: 0.015)
        
        // 4. 添加轻微的暗角
        outputImage = addVignette(to: outputImage, intensity: 0.3, radius: 1.5)
        
        return outputImage
    }
    
    private func applyCCDWarm(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // 1. 温暖的色温调整
        if let tempAndTint = CIFilter(name: "CITemperatureAndTint") {
            tempAndTint.setValue(outputImage, forKey: kCIInputImageKey)
            tempAndTint.setValue(CIVector(x: 6800, y: 0), forKey: "inputNeutral")
            tempAndTint.setValue(CIVector(x: 5500, y: 10), forKey: "inputTargetNeutral")
            outputImage = tempAndTint.outputImage ?? outputImage
        }
        
        // 2. 增强黄色调
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(0.95, forKey: kCIInputSaturationKey)
            colorControls.setValue(0.05, forKey: kCIInputBrightnessKey)
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        // 3. 添加胶片颗粒
        outputImage = addFilmGrain(to: outputImage, intensity: 0.02)
        
        return outputImage
    }
    
    private func applyCCDCool(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // 1. 冷色调调整
        if let tempAndTint = CIFilter(name: "CITemperatureAndTint") {
            tempAndTint.setValue(outputImage, forKey: kCIInputImageKey)
            tempAndTint.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            tempAndTint.setValue(CIVector(x: 7500, y: -10), forKey: "inputTargetNeutral")
            outputImage = tempAndTint.outputImage ?? outputImage
        }
        
        // 2. 增强蓝绿色调
        if let colorMatrix = CIFilter(name: "CIColorMatrix") {
            colorMatrix.setValue(outputImage, forKey: kCIInputImageKey)
            colorMatrix.setValue(CIVector(x: 0.9, y: 0, z: 0, w: 0), forKey: "inputRVector")
            colorMatrix.setValue(CIVector(x: 0, y: 1.05, z: 0, w: 0), forKey: "inputGVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0, z: 1.1, w: 0), forKey: "inputBVector")
            outputImage = colorMatrix.outputImage ?? outputImage
        }
        
        return outputImage
    }
    
    private func applyCCDNight(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // 1. 降低亮度，增加对比度
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(0.8, forKey: kCIInputSaturationKey)
            colorControls.setValue(-0.1, forKey: kCIInputBrightnessKey)
            colorControls.setValue(1.2, forKey: kCIInputContrastKey)
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        // 2. 增加噪点模拟高ISO
        outputImage = addDigitalNoise(to: outputImage, intensity: 0.04)
        
        // 3. 强化暗角
        outputImage = addVignette(to: outputImage, intensity: 0.6, radius: 1.2)
        
        return outputImage
    }
    
    // MARK: - Film Filters
    
    private func applyFuji400H(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // Fuji 400H特有的绿色偏移和柔和对比度
        if let colorMatrix = CIFilter(name: "CIColorMatrix") {
            colorMatrix.setValue(outputImage, forKey: kCIInputImageKey)
            colorMatrix.setValue(CIVector(x: 1.0, y: 0, z: 0, w: 0), forKey: "inputRVector")
            colorMatrix.setValue(CIVector(x: 0, y: 1.15, z: 0, w: 0), forKey: "inputGVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0.95, w: 0), forKey: "inputBVector")
            outputImage = colorMatrix.outputImage ?? outputImage
        }
        
        return outputImage
    }
    
    private func applyLeica(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // 降低曝光度 -10
        if let exposureAdjust = CIFilter(name: "CIExposureAdjust") {
            exposureAdjust.setValue(outputImage, forKey: kCIInputImageKey)
            exposureAdjust.setValue(-0.4, forKey: kCIInputEVKey) // 曝光-10对应约-0.4 EV
            outputImage = exposureAdjust.outputImage ?? outputImage
        }
        
        // 调整对比度 +30
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(1.3, forKey: kCIInputContrastKey) // 对比度+30
            colorControls.setValue(0.08, forKey: kCIInputBrightnessKey) // 亮度+8
            colorControls.setValue(0.9, forKey: kCIInputSaturationKey) // 饱和度-10
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        // 调整色温 -22 和色调 +10
        if let tempAndTint = CIFilter(name: "CITemperatureAndTint") {
            tempAndTint.setValue(outputImage, forKey: kCIInputImageKey)
            tempAndTint.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            tempAndTint.setValue(CIVector(x: 7300, y: 10), forKey: "inputTargetNeutral") // 色温-22，色调+10
            outputImage = tempAndTint.outputImage ?? outputImage
        }
        
        // 调整黑点 +22
        if let toneCurve = CIFilter(name: "CIToneCurve") {
            toneCurve.setValue(outputImage, forKey: kCIInputImageKey)
            toneCurve.setValue(CIVector(x: 0.0, y: 0.22), forKey: "inputPoint0") // 黑点+22
            toneCurve.setValue(CIVector(x: 0.25, y: 0.3), forKey: "inputPoint1") // 阴影-10
            toneCurve.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
            toneCurve.setValue(CIVector(x: 0.75, y: 0.7), forKey: "inputPoint3") // 高光-50
            toneCurve.setValue(CIVector(x: 1.0, y: 1.0), forKey: "inputPoint4")
            outputImage = toneCurve.outputImage ?? outputImage
        }
        
        // 调整锐度 +10 和清晰度 +20
        if let sharpenLuminance = CIFilter(name: "CISharpenLuminance") {
            sharpenLuminance.setValue(outputImage, forKey: kCIInputImageKey)
            sharpenLuminance.setValue(0.4, forKey: kCIInputSharpnessKey) // 锐度+10和清晰度+20的综合效果
            outputImage = sharpenLuminance.outputImage ?? outputImage
        }
        
        // 增加自然饱和度 +26 (通过调整某些色彩通道实现)
        if let colorMatrix = CIFilter(name: "CIColorMatrix") {
            colorMatrix.setValue(outputImage, forKey: kCIInputImageKey)
            colorMatrix.setValue(CIVector(x: 1.1, y: 0, z: 0, w: 0), forKey: "inputRVector")
            colorMatrix.setValue(CIVector(x: 0, y: 1.05, z: 0, w: 0), forKey: "inputGVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0, z: 1.15, w: 0), forKey: "inputBVector")
            outputImage = colorMatrix.outputImage ?? outputImage
        }
        
        // 添加晕影 +12
        outputImage = addVignette(to: outputImage, intensity: 0.12, radius: 1.2)
        
        return outputImage
    }
    
    private func applyKodakGold200(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // Kodak Gold的暖黄色调
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(1.1, forKey: kCIInputSaturationKey)
            colorControls.setValue(0.05, forKey: kCIInputBrightnessKey)
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        if let colorMatrix = CIFilter(name: "CIColorMatrix") {
            colorMatrix.setValue(outputImage, forKey: kCIInputImageKey)
            colorMatrix.setValue(CIVector(x: 1.15, y: 0, z: 0, w: 0), forKey: "inputRVector")
            colorMatrix.setValue(CIVector(x: 0, y: 1.05, z: 0, w: 0), forKey: "inputGVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0.9, w: 0), forKey: "inputBVector")
            outputImage = colorMatrix.outputImage ?? outputImage
        }
        
        return outputImage
    }
    
    private func applyAgfaVista(to image: CIImage) -> CIImage {
        // Agfa Vista的高饱和度和独特色彩
        var outputImage = image
        
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(1.3, forKey: kCIInputSaturationKey)
            colorControls.setValue(0.03, forKey: kCIInputBrightnessKey)
            colorControls.setValue(1.1, forKey: kCIInputContrastKey)
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        return outputImage
    }
    
    private func applyIlfordHP5(to image: CIImage) -> CIImage {
        // 黑白胶片效果
        var outputImage = image
        
        // 转换为黑白
        if let noir = CIFilter(name: "CIPhotoEffectNoir") {
            noir.setValue(outputImage, forKey: kCIInputImageKey)
            outputImage = noir.outputImage ?? outputImage
        }
        
        // 增加对比度和颗粒
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(1.3, forKey: kCIInputContrastKey)
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        outputImage = addFilmGrain(to: outputImage, intensity: 0.03)
        
        return outputImage
    }
    
    // MARK: - Vintage Filters
    
    private func applyVintage90s(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // 90年代特有的色彩风格
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(0.85, forKey: kCIInputSaturationKey)
            colorControls.setValue(0.1, forKey: kCIInputBrightnessKey)
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        // 添加漏光效果
        outputImage = addLightLeak(to: outputImage)
        
        return outputImage
    }
    
    private func applyRetrowave(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // 蒸汽波风格 - 强烈的紫色和青色
        if let colorMatrix = CIFilter(name: "CIColorMatrix") {
            colorMatrix.setValue(outputImage, forKey: kCIInputImageKey)
            colorMatrix.setValue(CIVector(x: 1.2, y: 0, z: 0.3, w: 0), forKey: "inputRVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0.8, z: 0.2, w: 0), forKey: "inputGVector")
            colorMatrix.setValue(CIVector(x: 0.2, y: 0, z: 1.5, w: 0), forKey: "inputBVector")
            outputImage = colorMatrix.outputImage ?? outputImage
        }
        
        return outputImage
    }
    
    private func applyLofi(to image: CIImage) -> CIImage {
        var outputImage = image
        
        // Lo-Fi效果 - 低保真度
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(1.2, forKey: kCIInputSaturationKey)
            colorControls.setValue(0.05, forKey: kCIInputBrightnessKey)
            colorControls.setValue(1.4, forKey: kCIInputContrastKey)
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        // 添加强烈的暗角
        outputImage = addVignette(to: outputImage, intensity: 0.8, radius: 1.0)
        
        // 添加颗粒
        outputImage = addFilmGrain(to: outputImage, intensity: 0.04)
        
        return outputImage
    }
    
    // MARK: - Helper Methods
    
    private func addDigitalNoise(to image: CIImage, intensity: Float) -> CIImage {
        guard let randomGenerator = CIFilter(name: "CIRandomGenerator"),
              let noiseImage = randomGenerator.outputImage else { return image }
        
        let croppedNoise = noiseImage.cropped(to: image.extent)
        
        guard let colorMatrix = CIFilter(name: "CIColorMatrix") else { return image }
        colorMatrix.setValue(croppedNoise, forKey: kCIInputImageKey)
        let alpha = CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity))
        colorMatrix.setValue(alpha, forKey: "inputAVector")
        
        guard let noisyImage = colorMatrix.outputImage,
              let composite = CIFilter(name: "CISourceOverCompositing") else { return image }
        
        composite.setValue(noisyImage, forKey: kCIInputImageKey)
        composite.setValue(image, forKey: kCIInputBackgroundImageKey)
        
        return composite.outputImage ?? image
    }
    
    private func addFilmGrain(to image: CIImage, intensity: Float) -> CIImage {
        // 类似数字噪点，但模式略有不同
        return addDigitalNoise(to: image, intensity: intensity * 1.2)
    }
    
    private func addVignette(to image: CIImage, intensity: Float, radius: Float) -> CIImage {
        guard let vignette = CIFilter(name: "CIVignette") else { return image }
        vignette.setValue(image, forKey: kCIInputImageKey)
        vignette.setValue(intensity, forKey: kCIInputIntensityKey)
        vignette.setValue(radius, forKey: kCIInputRadiusKey)
        return vignette.outputImage ?? image
    }
    
    private func addLightLeak(to image: CIImage) -> CIImage {
        // 简单的漏光效果 - 在角落添加亮光
        guard let radialGradient = CIFilter(name: "CIRadialGradient") else { return image }
        
        radialGradient.setValue(CIVector(x: image.extent.width * 0.9, y: image.extent.height * 0.9), forKey: "inputCenter")
        radialGradient.setValue(100, forKey: "inputRadius0")
        radialGradient.setValue(300, forKey: "inputRadius1")
        radialGradient.setValue(CIColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 0.3), forKey: "inputColor0")
        radialGradient.setValue(CIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 0), forKey: "inputColor1")
        
        guard let lightLeak = radialGradient.outputImage,
              let composite = CIFilter(name: "CISourceOverCompositing") else { return image }
        
        composite.setValue(lightLeak.cropped(to: image.extent), forKey: kCIInputImageKey)
        composite.setValue(image, forKey: kCIInputBackgroundImageKey)
        
        return composite.outputImage ?? image
    }
    
    private func getFilterIcon(for filter: FilterType) -> String {
        switch filter {
        case .none:
            return "circle"
        case .ccdClassic, .ccdWarm, .ccdCool, .ccdNight:
            return "camera.fill"
        case .fuji400H, .kodakGold200, .agfaVista, .ilfordHP5, .leica:
            return "film"
        case .vintage90s, .retrowave, .lofi:
            return "sparkles"
        case .leica:
            return "camera.aperture"
        }
    }
} 