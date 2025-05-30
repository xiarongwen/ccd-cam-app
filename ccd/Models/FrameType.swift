//
//  FrameType.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import Foundation
import SwiftUI

enum FrameType: String, CaseIterable {
    case none = "none"
    case polaroid = "polaroid"
    case polaroidVintage = "polaroid_vintage"
    case filmStrip = "film_strip"
    case instant = "instant"
    case classicWhite = "classic_white"
    case classicBlack = "classic_black"
    case retro90s = "retro_90s"
    
    var displayName: String {
        switch self {
        case .none:
            return "无相框"
        case .polaroid:
            return "拍立得"
        case .polaroidVintage:
            return "复古拍立得"
        case .filmStrip:
            return "胶片条"
        case .instant:
            return "即时相片"
        case .classicWhite:
            return "经典白框"
        case .classicBlack:
            return "经典黑框"
        case .retro90s:
            return "90年代"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .none, .polaroid, .classicWhite:
            return false
        default:
            return true
        }
    }
    
    // 相框的边距和样式参数
    var frameParams: FrameParams {
        switch self {
        case .none:
            return FrameParams(topPadding: 0, sidePadding: 0, bottomPadding: 0, cornerRadius: 0, color: .clear)
        case .polaroid:
            return FrameParams(topPadding: 40, sidePadding: 40, bottomPadding: 120, cornerRadius: 8, color: .white)
        case .polaroidVintage:
            return FrameParams(topPadding: 50, sidePadding: 45, bottomPadding: 140, cornerRadius: 12, color: Color(red: 0.98, green: 0.96, blue: 0.92))
        case .filmStrip:
            return FrameParams(topPadding: 60, sidePadding: 20, bottomPadding: 60, cornerRadius: 4, color: .black)
        case .instant:
            return FrameParams(topPadding: 30, sidePadding: 30, bottomPadding: 100, cornerRadius: 6, color: .white)
        case .classicWhite:
            return FrameParams(topPadding: 80, sidePadding: 80, bottomPadding: 80, cornerRadius: 0, color: .white)
        case .classicBlack:
            return FrameParams(topPadding: 80, sidePadding: 80, bottomPadding: 80, cornerRadius: 0, color: .black)
        case .retro90s:
            return FrameParams(topPadding: 20, sidePadding: 20, bottomPadding: 20, cornerRadius: 15, color: Color(red: 0.2, green: 0.8, blue: 0.9))
        }
    }
}

struct FrameParams {
    let topPadding: CGFloat
    let sidePadding: CGFloat
    let bottomPadding: CGFloat
    let cornerRadius: CGFloat
    let color: Color
} 