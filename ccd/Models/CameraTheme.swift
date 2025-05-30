//
//  CameraTheme.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

// MARK: - 相机UI主题
struct CameraTheme {
    let id: String
    let name: String
    let brandName: String
    let brandSubtitle: String
    let brandColor: Color
    let backgroundColor: LinearGradient
    let lensStyle: LensStyle
    let bodyStyle: BodyStyle
    let buttonStyle: ButtonStyle
    let indicatorStyle: IndicatorStyle
    let soundEffect: String?
    
    // MARK: - 镜头样式
    struct LensStyle {
        let outerColor: RadialGradient
        let innerColor: Color
        let reflectionColors: [Color]
        let size: CGFloat
        let borderColor: Color
        let markingText: String
        let markingColor: Color
    }
    
    // MARK: - 机身样式
    struct BodyStyle {
        let material: MaterialType
        let texture: String?
        let decorativeElements: [DecorativeElement]
        
        enum MaterialType {
            case metal, plastic, leather, ceramic
        }
        
        struct DecorativeElement {
            let type: ElementType
            let position: CGPoint
            let color: Color
            
            enum ElementType {
                case screw, logo, ventilation, grip
            }
        }
    }
    
    // MARK: - 按钮样式
    struct ButtonStyle {
        let shutterColor: RadialGradient
        let shutterBorder: Color
        let controlColor: Color
        let activeColor: Color
        let shadowRadius: CGFloat
    }
    
    // MARK: - 指示器样式
    struct IndicatorStyle {
        let backgroundColor: Color
        let textColor: Color
        let accentColor: Color
        let borderColor: Color
        let font: Font
    }
}

// MARK: - 滤镜对应的主题映射
extension FilterType {
    var cameraTheme: CameraTheme {
        switch self {
        case .none:
            return .modern
        case .ccdClassic:
            return .classicSilver
        case .ccdWarm:
            return .vintageGold
        case .ccdCool:
            return .coolBlue
        case .ccdNight:
            return .nightBlack
        case .fuji400H:
            return .fujiGreen
        case .kodakGold200:
            return .kodakYellow
        case .agfaVista:
            return .agfaRed
        case .ilfordHP5:
            return .ilfordBlack
        case .leica:
            return .leicaClassic
        case .vintage90s:
            return .retro90s
        case .retrowave:
            return .synthwave
        case .lofi:
            return .lofiPink
        }
    }
}

// MARK: - 预定义主题
extension CameraTheme {
    
    // 现代简洁 - 原图
    static let modern = CameraTheme(
        id: "modern",
        name: "Modern",
        brandName: "NOMO CAM",
        brandSubtitle: "135 P",
        brandColor: .black,
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.95, blue: 0.95),
                Color(red: 0.92, green: 0.92, blue: 0.92)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(white: 0.85),
                    Color(white: 0.75),
                    Color(white: 0.65)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.blue.opacity(0.1), .purple.opacity(0.05)],
            size: 240,
            borderColor: Color(white: 0.5),
            markingText: "WIDE",
            markingColor: .white
        ),
        bodyStyle: BodyStyle(
            material: .plastic,
            texture: nil,
            decorativeElements: []
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.red.opacity(0.8), Color.red],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: .white,
            controlColor: .black,
            activeColor: .red,
            shadowRadius: 8
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color.white.opacity(0.8),
            textColor: .black,
            accentColor: .red,
            borderColor: Color.black.opacity(0.3),
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "modern_shutter"
    )
    
    // 经典银色 - CCD经典
    static let classicSilver = CameraTheme(
        id: "classic_silver",
        name: "Classic Silver",
        brandName: "CCD CLASSIC",
        brandSubtitle: "DIGITAL",
        brandColor: .black,
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.85, green: 0.85, blue: 0.87),
                Color(red: 0.80, green: 0.80, blue: 0.82)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(white: 0.9),
                    Color(white: 0.8),
                    Color(white: 0.7)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.white.opacity(0.2), .gray.opacity(0.1)],
            size: 240,
            borderColor: Color(white: 0.6),
            markingText: "AF NIKKOR",
            markingColor: .white
        ),
        bodyStyle: BodyStyle(
            material: .metal,
            texture: "brushed_metal",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .screw, position: CGPoint(x: 0.1, y: 0.1), color: .gray),
                BodyStyle.DecorativeElement(type: .screw, position: CGPoint(x: 0.9, y: 0.1), color: .gray)
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.gray.opacity(0.8), Color.gray],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(white: 0.9),
            controlColor: .black,
            activeColor: .blue,
            shadowRadius: 6
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color.black.opacity(0.8),
            textColor: .green,
            accentColor: .green,
            borderColor: Color.gray,
            font: .system(size: 8, weight: .bold, design: .monospaced)
        ),
        soundEffect: "classic_shutter"
    )
    
    // 复古金色 - CCD暖调
    static let vintageGold = CameraTheme(
        id: "vintage_gold",
        name: "Vintage Gold",
        brandName: "VINTAGE CAM",
        brandSubtitle: "GOLD EDITION",
        brandColor: Color(red: 0.8, green: 0.6, blue: 0.2),
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.90, blue: 0.80),
                Color(red: 0.90, green: 0.85, blue: 0.75)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(red: 0.9, green: 0.8, blue: 0.6),
                    Color(red: 0.8, green: 0.7, blue: 0.5),
                    Color(red: 0.7, green: 0.6, blue: 0.4)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.orange.opacity(0.2), .yellow.opacity(0.1)],
            size: 240,
            borderColor: Color(red: 0.6, green: 0.5, blue: 0.3),
            markingText: "WARM LENS",
            markingColor: Color(red: 0.8, green: 0.6, blue: 0.2)
        ),
        bodyStyle: BodyStyle(
            material: .leather,
            texture: "vintage_leather",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.2), color: Color(red: 0.8, green: 0.6, blue: 0.2))
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.orange.opacity(0.8), Color.orange],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(red: 0.8, green: 0.6, blue: 0.2),
            controlColor: Color(red: 0.6, green: 0.4, blue: 0.2),
            activeColor: .orange,
            shadowRadius: 10
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color(red: 0.9, green: 0.8, blue: 0.6).opacity(0.9),
            textColor: Color(red: 0.6, green: 0.4, blue: 0.2),
            accentColor: .orange,
            borderColor: Color(red: 0.8, green: 0.6, blue: 0.2),
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "vintage_shutter"
    )
    
    // 冷蓝色 - CCD冷调
    static let coolBlue = CameraTheme(
        id: "cool_blue",
        name: "Cool Blue",
        brandName: "ARCTIC CAM",
        brandSubtitle: "ICE EDITION",
        brandColor: Color(red: 0.2, green: 0.4, blue: 0.8),
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.85, green: 0.90, blue: 0.95),
                Color(red: 0.80, green: 0.85, blue: 0.92)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(red: 0.8, green: 0.85, blue: 0.9),
                    Color(red: 0.7, green: 0.8, blue: 0.85),
                    Color(red: 0.6, green: 0.7, blue: 0.8)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
            size: 240,
            borderColor: Color(red: 0.4, green: 0.6, blue: 0.8),
            markingText: "COOL LENS",
            markingColor: .cyan
        ),
        bodyStyle: BodyStyle(
            material: .ceramic,
            texture: "ceramic_finish",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .ventilation, position: CGPoint(x: 0.8, y: 0.3), color: Color(red: 0.5, green: 0.7, blue: 0.9))
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.blue.opacity(0.8), Color.blue],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: .cyan,
            controlColor: Color(red: 0.3, green: 0.5, blue: 0.7),
            activeColor: .cyan,
            shadowRadius: 8
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.9),
            textColor: Color(red: 0.2, green: 0.4, blue: 0.8),
            accentColor: .cyan,
            borderColor: Color(red: 0.4, green: 0.6, blue: 0.8),
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "cool_shutter"
    )
    
    // 夜黑色 - CCD夜景
    static let nightBlack = CameraTheme(
        id: "night_black",
        name: "Night Black",
        brandName: "NIGHT VISION",
        brandSubtitle: "PRO DARK",
        brandColor: .white,
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.1),
                Color(red: 0.05, green: 0.05, blue: 0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(white: 0.3),
                    Color(white: 0.2),
                    Color(white: 0.1)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.purple.opacity(0.3), .blue.opacity(0.2)],
            size: 240,
            borderColor: Color(white: 0.4),
            markingText: "NIGHT VISION",
            markingColor: .green
        ),
        bodyStyle: BodyStyle(
            material: .metal,
            texture: "matte_black",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .grip, position: CGPoint(x: 0.2, y: 0.7), color: Color(white: 0.2))
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.purple.opacity(0.8), Color.purple],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: .green,
            controlColor: Color(white: 0.3),
            activeColor: .green,
            shadowRadius: 12
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color.black.opacity(0.9),
            textColor: .green,
            accentColor: .green,
            borderColor: Color(white: 0.3),
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "night_shutter"
    )
    
    // 富士绿色 - 富士400H
    static let fujiGreen = CameraTheme(
        id: "fuji_green",
        name: "Fuji Green",
        brandName: "FUJIFILM",
        brandSubtitle: "400H FILM",
        brandColor: Color(red: 0.0, green: 0.5, blue: 0.2),
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.98, blue: 0.95),
                Color(red: 0.90, green: 0.95, blue: 0.90)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(red: 0.9, green: 0.95, blue: 0.9),
                    Color(red: 0.8, green: 0.9, blue: 0.8),
                    Color(red: 0.7, green: 0.8, blue: 0.7)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.green.opacity(0.2), .mint.opacity(0.1)],
            size: 240,
            borderColor: Color(red: 0.0, green: 0.6, blue: 0.2),
            markingText: "FUJINON",
            markingColor: Color(red: 0.0, green: 0.5, blue: 0.2)
        ),
        bodyStyle: BodyStyle(
            material: .plastic,
            texture: "fuji_texture",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.15), color: Color(red: 0.0, green: 0.5, blue: 0.2))
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.green.opacity(0.8), Color.green],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(red: 0.0, green: 0.7, blue: 0.2),
            controlColor: Color(red: 0.0, green: 0.4, blue: 0.1),
            activeColor: .green,
            shadowRadius: 8
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color(red: 0.9, green: 1.0, blue: 0.9).opacity(0.9),
            textColor: Color(red: 0.0, green: 0.5, blue: 0.2),
            accentColor: .green,
            borderColor: Color(red: 0.0, green: 0.6, blue: 0.2),
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "film_advance"
    )
    
    // 柯达黄色 - 柯达Gold
    static let kodakYellow = CameraTheme(
        id: "kodak_yellow",
        name: "Kodak Gold",
        brandName: "KODAK",
        brandSubtitle: "GOLD 200",
        brandColor: Color(red: 0.8, green: 0.2, blue: 0.0),
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.95, blue: 0.0),
                Color(red: 0.95, green: 0.85, blue: 0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.2),
                    Color(red: 0.9, green: 0.8, blue: 0.1),
                    Color(red: 0.8, green: 0.7, blue: 0.0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
            size: 240,
            borderColor: Color(red: 0.8, green: 0.2, blue: 0.0),
            markingText: "KODAK LENS",
            markingColor: Color(red: 0.8, green: 0.2, blue: 0.0)
        ),
        bodyStyle: BodyStyle(
            material: .plastic,
            texture: "kodak_plastic",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.2), color: Color(red: 0.8, green: 0.2, blue: 0.0))
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.red.opacity(0.8), Color.red],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(red: 0.8, green: 0.2, blue: 0.0),
            controlColor: Color(red: 0.6, green: 0.1, blue: 0.0),
            activeColor: .red,
            shadowRadius: 8
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color.yellow.opacity(0.9),
            textColor: Color(red: 0.8, green: 0.2, blue: 0.0),
            accentColor: .red,
            borderColor: Color(red: 0.8, green: 0.2, blue: 0.0),
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "kodak_click"
    )
    
    // 爱克发红色 - 爱克发Vista
    static let agfaRed = CameraTheme(
        id: "agfa_red",
        name: "Agfa Red",
        brandName: "AGFA",
        brandSubtitle: "VISTA 200",
        brandColor: .white,
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.8, green: 0.2, blue: 0.2),
                Color(red: 0.7, green: 0.1, blue: 0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(red: 0.9, green: 0.3, blue: 0.3),
                    Color(red: 0.8, green: 0.2, blue: 0.2),
                    Color(red: 0.7, green: 0.1, blue: 0.1)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.red.opacity(0.3), .orange.opacity(0.2)],
            size: 240,
            borderColor: .white,
            markingText: "AGFA LENS",
            markingColor: .white
        ),
        bodyStyle: BodyStyle(
            material: .plastic,
            texture: "agfa_red",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.15), color: .white)
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.white.opacity(0.9), Color.white],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(red: 0.8, green: 0.2, blue: 0.2),
            controlColor: .white,
            activeColor: .yellow,
            shadowRadius: 8
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color.white.opacity(0.9),
            textColor: Color(red: 0.8, green: 0.2, blue: 0.2),
            accentColor: .yellow,
            borderColor: .white,
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "agfa_shutter"
    )
    
    // 依尔福黑色 - 依尔福HP5
    static let ilfordBlack = CameraTheme(
        id: "ilford_black",
        name: "Ilford Black",
        brandName: "ILFORD",
        brandSubtitle: "HP5 PLUS",
        brandColor: .white,
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.2, blue: 0.2),
                Color(red: 0.1, green: 0.1, blue: 0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(white: 0.4),
                    Color(white: 0.3),
                    Color(white: 0.2)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.white.opacity(0.1), .gray.opacity(0.1)],
            size: 240,
            borderColor: .white,
            markingText: "ILFORD",
            markingColor: .white
        ),
        bodyStyle: BodyStyle(
            material: .metal,
            texture: "brushed_black",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.2), color: .white)
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.gray.opacity(0.8), Color.gray],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: .white,
            controlColor: Color(white: 0.7),
            activeColor: .white,
            shadowRadius: 6
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color.black.opacity(0.9),
            textColor: .white,
            accentColor: .white,
            borderColor: Color(white: 0.3),
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "mechanical_shutter"
    )
    
    // 莱卡经典 - 莱卡
    static let leicaClassic = CameraTheme(
        id: "leica_classic",
        name: "Leica Classic",
        brandName: "LEICA",
        brandSubtitle: "WETZLAR",
        brandColor: .red,
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.9, green: 0.9, blue: 0.9),
                Color(red: 0.85, green: 0.85, blue: 0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(white: 0.95),
                    Color(white: 0.9),
                    Color(white: 0.85)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.white.opacity(0.3), .blue.opacity(0.1)],
            size: 240,
            borderColor: Color(white: 0.7),
            markingText: "SUMMICRON",
            markingColor: .black
        ),
        bodyStyle: BodyStyle(
            material: .metal,
            texture: "leica_chrome",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.18), color: .red),
                BodyStyle.DecorativeElement(type: .screw, position: CGPoint(x: 0.2, y: 0.8), color: Color(white: 0.6))
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.red.opacity(0.8), Color.red],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(white: 0.9),
            controlColor: .black,
            activeColor: .red,
            shadowRadius: 4
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color.white.opacity(0.95),
            textColor: .black,
            accentColor: .red,
            borderColor: Color(white: 0.7),
            font: .system(size: 9, weight: .medium, design: .serif)
        ),
        soundEffect: "leica_shutter"
    )
    
    // 90年代复古 - 90年代
    static let retro90s = CameraTheme(
        id: "retro_90s",
        name: "Retro 90s",
        brandName: "RETRO CAM",
        brandSubtitle: "90's EDITION",
        brandColor: Color(red: 0.8, green: 0.2, blue: 0.8),
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.85, blue: 0.95),
                Color(red: 0.90, green: 0.80, blue: 0.90)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(red: 0.9, green: 0.8, blue: 0.9),
                    Color(red: 0.8, green: 0.7, blue: 0.8),
                    Color(red: 0.7, green: 0.6, blue: 0.7)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.purple.opacity(0.2), .pink.opacity(0.1)],
            size: 240,
            borderColor: Color(red: 0.8, green: 0.2, blue: 0.8),
            markingText: "RETRO",
            markingColor: Color(red: 0.8, green: 0.2, blue: 0.8)
        ),
        bodyStyle: BodyStyle(
            material: .plastic,
            texture: "90s_plastic",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.2), color: Color(red: 0.8, green: 0.2, blue: 0.8))
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.pink.opacity(0.8), Color.pink],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(red: 0.8, green: 0.2, blue: 0.8),
            controlColor: Color(red: 0.6, green: 0.1, blue: 0.6),
            activeColor: .pink,
            shadowRadius: 8
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color(red: 0.95, green: 0.85, blue: 0.95).opacity(0.9),
            textColor: Color(red: 0.8, green: 0.2, blue: 0.8),
            accentColor: .pink,
            borderColor: Color(red: 0.8, green: 0.2, blue: 0.8),
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "90s_beep"
    )
    
    // 蒸汽波 - 蒸汽波
    static let synthwave = CameraTheme(
        id: "synthwave",
        name: "Synthwave",
        brandName: "SYNTH CAM",
        brandSubtitle: "VAPORWAVE",
        brandColor: Color(red: 1.0, green: 0.0, blue: 1.0),
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.0, blue: 0.3),
                Color(red: 0.2, green: 0.0, blue: 0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(red: 0.5, green: 0.0, blue: 0.8),
                    Color(red: 0.3, green: 0.0, blue: 0.6),
                    Color(red: 0.1, green: 0.0, blue: 0.4)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.cyan.opacity(0.5), Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.3)],
            size: 240,
            borderColor: .cyan,
            markingText: "NEON",
            markingColor: .cyan
        ),
        bodyStyle: BodyStyle(
            material: .plastic,
            texture: "neon_grid",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.15), color: .cyan)
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.cyan.opacity(0.8), Color.cyan],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(red: 1.0, green: 0.0, blue: 1.0),
            controlColor: .cyan,
            activeColor: Color(red: 1.0, green: 0.0, blue: 1.0),
            shadowRadius: 15
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color.black.opacity(0.8),
            textColor: .cyan,
            accentColor: Color(red: 1.0, green: 0.0, blue: 1.0),
            borderColor: .cyan,
            font: .system(size: 10, weight: .bold, design: .monospaced)
        ),
        soundEffect: "synthwave_beep"
    )
    
    // Lo-Fi粉色 - Lo-Fi
    static let lofiPink = CameraTheme(
        id: "lofi_pink",
        name: "Lo-Fi Pink",
        brandName: "LO-FI CAM",
        brandSubtitle: "CHILL MODE",
        brandColor: Color(red: 0.8, green: 0.4, blue: 0.6),
        backgroundColor: LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.9, blue: 0.95),
                Color(red: 0.95, green: 0.85, blue: 0.9)
            ],
            startPoint: .top,
            endPoint: .bottom
        ),
        lensStyle: LensStyle(
            outerColor: RadialGradient(
                colors: [
                    Color(red: 0.95, green: 0.8, blue: 0.9),
                    Color(red: 0.9, green: 0.7, blue: 0.8),
                    Color(red: 0.85, green: 0.6, blue: 0.7)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            ),
            innerColor: .black,
            reflectionColors: [.pink.opacity(0.3), .purple.opacity(0.2)],
            size: 240,
            borderColor: Color(red: 0.8, green: 0.4, blue: 0.6),
            markingText: "CHILL",
            markingColor: Color(red: 0.8, green: 0.4, blue: 0.6)
        ),
        bodyStyle: BodyStyle(
            material: .plastic,
            texture: "soft_matte",
            decorativeElements: [
                BodyStyle.DecorativeElement(type: .logo, position: CGPoint(x: 0.5, y: 0.2), color: Color(red: 0.8, green: 0.4, blue: 0.6))
            ]
        ),
        buttonStyle: ButtonStyle(
            shutterColor: RadialGradient(
                colors: [Color.pink.opacity(0.7), Color.pink],
                center: .center,
                startRadius: 0,
                endRadius: 25
            ),
            shutterBorder: Color(red: 0.8, green: 0.4, blue: 0.6),
            controlColor: Color(red: 0.7, green: 0.3, blue: 0.5),
            activeColor: .pink,
            shadowRadius: 6
        ),
        indicatorStyle: IndicatorStyle(
            backgroundColor: Color(red: 1.0, green: 0.95, blue: 0.98).opacity(0.9),
            textColor: Color(red: 0.8, green: 0.4, blue: 0.6),
            accentColor: .pink,
            borderColor: Color(red: 0.8, green: 0.4, blue: 0.6),
            font: .system(size: 10, weight: .medium, design: .rounded)
        ),
        soundEffect: "soft_click"
    )
} 