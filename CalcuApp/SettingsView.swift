//
//  SettingsView.swift
//  CalcuApp
//
//  Created by Ramiro Nehuen Sanabria on 17/10/2025.
//

import SwiftUI

/// Define los esquemas de color disponibles en la app.
enum AppColorScheme: String, CaseIterable, Identifiable {
    case dark = "Oscuro"
    case light = "Claro"
    
    var id: String { self.rawValue }
}

struct SettingsView: View {
    // @AppStorage guarda y lee valores de UserDefaults automáticamente.
    // Es perfecto para persistir configuraciones de usuario.
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("shakeToClearEnabled") private var shakeToClearEnabled: Bool = true
    @AppStorage("colorScheme") private var colorScheme: AppColorScheme = .dark
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // Se ha eliminado el ZStack y el fondo .ultraThinMaterial para evitar el doble efecto visual.
        NavigationView {
            Form {
                Section(header: Text("Sonido")) {
                    Toggle("Sonido de teclas", isOn: $soundEnabled)
                }
                
                Section(header: Text("Gestos")) {
                    Toggle("Agitar para borrar todo", isOn: $shakeToClearEnabled)
                }

                Section(header: Text("Apariencia")) {
                    Picker("Tema", selection: $colorScheme) {
                        ForEach(AppColorScheme.allCases) { scheme in
                            Text(scheme.rawValue).tag(scheme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Link("Acerca del creador", destination: URL(string: "https://ramirosanabria.dev")!)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // **NUEVO:** Botón para restablecer la configuración a los valores por defecto.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Restablecer") {
                        soundEnabled = true
                        shakeToClearEnabled = true
                        colorScheme = .dark
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hecho") {
                        dismiss()
                    }
                }
            }
        }
    }
}
