//
//  ccdApp.swift
//  ccd
//
//  Created by IT on 2025/5/23.
//

import SwiftUI

@main
struct ccdApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .preferredColorScheme(ColorScheme.dark) // 强制使用深色模式
        }
    }
}
