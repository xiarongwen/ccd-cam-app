//
//  FilterType.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import Foundation

enum FilterType: String, CaseIterable {
    // CCD系列
    case none = "none"
    case ccdClassic = "ccd_classic"
    case ccdWarm = "ccd_warm"
    case ccdCool = "ccd_cool"
    case ccdNight = "ccd_night"
    
    // 胶片系列
    case fuji400H = "fuji_400h"
    case kodakGold200 = "kodak_gold_200"
    case agfaVista = "agfa_vista"
    case ilfordHP5 = "ilford_hp5"
    case leica = "leica"
    
    // 复古效果
    case vintage90s = "vintage_90s"
    case retrowave = "retrowave"
    case lofi = "lofi"
    
    var displayName: String {
        switch self {
        case .none:
            return "原图"
        case .ccdClassic:
            return "CCD 经典"
        case .ccdWarm:
            return "CCD 暖调"
        case .ccdCool:
            return "CCD 冷调"
        case .ccdNight:
            return "CCD 夜景"
        case .fuji400H:
            return "富士 400H"
        case .kodakGold200:
            return "柯达 Gold"
        case .agfaVista:
            return "爱克发 Vista"
        case .ilfordHP5:
            return "依尔福 HP5"
        case .leica:
            return "莱卡"
        case .vintage90s:
            return "90年代"
        case .retrowave:
            return "蒸汽波"
        case .lofi:
            return "Lo-Fi"
        }
    }
    
    var icon: String {
        // 返回对应的图标名称
        return "filter_\(rawValue)"
    }
    
    var isPremium: Bool {
        // 标记哪些是高级滤镜
        switch self {
        case .none, .ccdClassic, .ccdWarm, .vintage90s, .leica:
            return false
        default:
            return true
        }
    }
} 