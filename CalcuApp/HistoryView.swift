//
//  HistoryView.swift
//  CalcuApp
//
//  Created by Ramiro Nehuen Sanabria on 17/10/2025.
//

import SwiftUI
import UIKit // Importamos UIKit para acceder al portapapeles (UIPasteboard).

struct HistoryView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.history.isEmpty {
                    Text("No hay historial todavía.")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        // Iteramos sobre cada entrada del historial.
                        ForEach(viewModel.history, id: \.self) { entry in
                            Text(entry)
                                // Añadimos un menú contextual que aparece al mantener pulsado el texto.
                                .contextMenu {
                                    // Opción para copiar la expresión completa.
                                    Button {
                                        // Copiamos la cadena completa al portapapeles.
                                        UIPasteboard.general.string = entry
                                    } label: {
                                        // Usamos Label para tener texto e icono.
                                        Label("Copiar expresión completa", systemImage: "doc.on.doc")
                                    }

                                    // Opción para copiar solo el resultado.
                                    Button {
                                        // Dividimos la cadena por " = " y tomamos la última parte, que es el resultado.
                                        if let result = entry.components(separatedBy: " = ").last {
                                            // Limpiamos espacios en blanco y copiamos al portapapeles.
                                            UIPasteboard.general.string = result.trimmingCharacters(in: .whitespaces)
                                        }
                                    } label: {
                                        Label("Copiar resultado", systemImage: "number")
                                    }
                                }
                        }
                    }
                    // Damos un estilo plano a la lista para que se integre mejor.
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Borrar") {
                        viewModel.clearHistory()
                    }
                    .disabled(viewModel.history.isEmpty)
                    // Se ha eliminado .buttonStyle(GlassButtonStyle())
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hecho") {
                        dismiss()
                    }
                    // Se ha eliminado .buttonStyle(GlassButtonStyle())
                }
            }
        }
    }
}
