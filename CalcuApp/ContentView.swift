//
//  ContentView.swift
//  CalcuApp
//
//  Created by Ramiro Nehuen Sanabria on 17/10/2025.
//

import SwiftUI
import UIKit // Importamos UIKit para poder usar el sonido del sistema.

struct ContentView: View {
    // La vista se suscribe a los cambios del ViewModel para actualizarse automáticamente.
    @StateObject private var viewModel = CalculatorViewModel()
    @State private var showingHistory = false
    @State private var showingSettings = false
    
    // Variable de estado para controlar la pulsación del botón de borrar.
    @State private var isPressingClear = false
    // Generador de feedback háptico.
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    // Leemos la configuración de sonido guardada por el usuario.
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    // Obtenemos el esquema de color actual del entorno para adaptar la UI.
    @Environment(\.colorScheme) var colorScheme

    // Definición de la cuadrícula de botones para facilitar el layout.
    let buttons: [[CalculatorButton]] = [
        [.leftParen, .rightParen, .percent, .clear, .divide],
        [.seven, .eight, .nine, .multiply, .subtract],
        [.four, .five, .six, .add, .equals],
        [.one, .two, .three, .zero, .decimal]
    ]

    var body: some View {
        // Usamos NavigationView para tener una barra de título y botones de acción.
        NavigationView {
            // Usamos GeometryReader para que los botones se adapten al tamaño de la pantalla.
            GeometryReader { geometry in
                let columns = buttons.first?.count ?? 5
                let buttonSize = (geometry.size.width - CGFloat(columns + 1) * 12) / CGFloat(columns)

                ZStack {
                    // Usamos un color de fondo del sistema que se adapta al tema.
                    Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)

                    VStack(spacing: 12) {
                        Spacer()
                        
                        // Pantalla de la calculadora donde se muestra la expresión y el resultado.
                        HStack {
                            Spacer()
                            Text(viewModel.display)
                                .font(.system(size: 90))
                                .fontWeight(.light)
                                // Usamos el color primario del sistema para el texto.
                                .foregroundColor(.primary)
                                .padding()
                                .lineLimit(1)
                                .minimumScaleFactor(0.3)
                        }

                        // Cuadrícula de botones generada dinámicamente.
                        ForEach(buttons, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(row, id: \.self) { button in
                                    // Lógica condicional para el botón .clear
                                    if button == .clear {
                                        Button(action: {
                                            // Acción para un TOQUE CORTO: Borrar un carácter (lógica de .delete)
                                            if soundEnabled {
                                                UIDevice.current.playInputClick()
                                            }
                                            viewModel.buttonTapped(.delete)
                                        }) {
                                            // El texto cambia si se está presionando el botón
                                            Text(isPressingClear ? "AC" : "←")
                                                .font(.system(size: 32))
                                                .frame(width: buttonSize, height: buttonSize)
                                                .background(button.backgroundColor(for: colorScheme))
                                                .foregroundColor(button.foregroundColor(for: colorScheme))
                                                .cornerRadius(buttonSize / 2)
                                        }
                                        // Gesto para la PULSACIÓN LARGA
                                        .onLongPressGesture(minimumDuration: 0.5, perform: {
                                            // Acción al completarse la pulsación larga: Borrar todo (lógica de .clear)
                                            if soundEnabled {
                                                UIDevice.current.playInputClick()
                                            }
                                            // 1. Generamos la vibración.
                                            feedbackGenerator.impactOccurred()
                                            // 2. Borramos solo la pantalla.
                                            viewModel.buttonTapped(.clear)
                                        }, onPressingChanged: { isPressing in
                                            // Actualiza el estado para cambiar el texto del botón
                                            self.isPressingClear = isPressing
                                        })
                                    } else {
                                        // Comportamiento normal para el resto de los botones
                                        Button(action: {
                                            if soundEnabled {
                                                UIDevice.current.playInputClick()
                                            }
                                            viewModel.buttonTapped(button)
                                        }) {
                                            Text(button.title)
                                                .font(.system(size: 32))
                                                // **INICIO DEL CAMBIO**
                                                // Añade un desplazamiento para centrar ópticamente los paréntesis.
                                                // Mueve "(" a la izquierda y ")" a la derecha.
                                                .offset(x: button == .leftParen ? -2.5 : (button == .rightParen ? 2.5 : 0))
                                                // **FIN DEL CAMBIO**
                                                .frame(width: buttonSize, height: buttonSize)
                                                .background(button.backgroundColor(for: colorScheme))
                                                .foregroundColor(button.foregroundColor(for: colorScheme))
                                                .cornerRadius(buttonSize / 2)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal, 12)
                }
                .toolbar {
                    // Barra de herramientas para botones de acción.
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingHistory.toggle()
                        }) {
                            Image(systemName: "clock.arrow.circlepath")
                        }

                        Button(action: {
                            // Este botón ahora muestra la vista de configuración.
                            showingSettings.toggle()
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showingHistory) {
                    HistoryView(viewModel: viewModel)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                // El color del toolbar también debe adaptarse.
                .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
            }
        }
        .onShake {
            // Al agitar, borramos la pantalla (AC) y el historial.
            feedbackGenerator.impactOccurred()
            viewModel.buttonTapped(.clear)
            viewModel.clearHistory()
        }
        .onAppear {
            // Preparamos el generador de vibración para reducir latencia.
            feedbackGenerator.prepare()
        }
    }
}

#Preview {
    ContentView()
}
