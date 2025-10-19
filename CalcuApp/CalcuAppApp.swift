//
//  CalcuAppApp.swift
//  CalcuApp
//
//  Created by Ramiro Nehuen Sanabria on 17/10/2025.
//

import SwiftUI

@main
struct CalcuAppApp: App {
    // Leemos la preferencia de tema del usuario para aplicarla a toda la app.
    @AppStorage("colorScheme") private var colorScheme: AppColorScheme = .dark

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Aplicamos el tema preferido por el usuario a la vista principal.
                .preferredColorScheme(colorScheme == .dark ? .dark : .light)
        }
    }
}
