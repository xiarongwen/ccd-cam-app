//
//  WatermarkType.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import Foundation
import SwiftUI

enum WatermarkType: String, CaseIterable {
    case none = "none"
    case timestamp = "timestamp"
    case ccdBrand = "ccd_brand"
    case vintage = "vintage"
    case filmDate = "film_date"
    case customText = "custom_text"
    
    var displayName: String {
        switch self {
        case .none:
            return "无水印"
        case .timestamp:
            return "时间戳"
        case .ccdBrand:
            return "CCD品牌"
        case .vintage:
            return "复古标记"
        case .filmDate:
            return "胶片日期"
        case .customText:
            return "自定义文字"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .none, .timestamp, .ccdBrand:
            return false
        default:
            return true
        }
    }
    
    func getText(customText: String = "") -> String {
        let dateFormatter = DateFormatter()
        
        switch self {
        case .none:
            return ""
        case .timestamp:
            dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
            return dateFormatter.string(from: Date())
        case .ccdBrand:
            return "CCD FILM CAMERA"
        case .vintage:
            dateFormatter.dateFormat = "'90s MM.dd"
            return dateFormatter.string(from: Date())
        case .filmDate:
            dateFormatter.dateFormat = "yyyy/MM/dd"
            return "FILM " + dateFormatter.string(from: Date())
        case .customText:
            return customText.isEmpty ? "Custom Text" : customText
        }
    }
    
    var textStyle: WatermarkStyle {
        switch self {
        case .none:
            return WatermarkStyle(font: .caption, color: .clear, position: .bottomTrailing)
        case .timestamp:
            return WatermarkStyle(font: .caption, color: .white, position: .bottomTrailing)
        case .ccdBrand:
            return WatermarkStyle(font: .caption2, color: .yellow, position: .bottomLeading)
        case .vintage:
            return WatermarkStyle(font: .caption, color: .orange, position: .topTrailing)
        case .filmDate:
            return WatermarkStyle(font: .caption2, color: .white, position: .bottomCenter)
        case .customText:
            return WatermarkStyle(font: .caption, color: .white, position: .bottomTrailing)
        }
    }
}

struct WatermarkStyle {
    let font: Font
    let color: Color
    let position: WatermarkPosition
}

enum WatermarkPosition {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    case bottomCenter
} 