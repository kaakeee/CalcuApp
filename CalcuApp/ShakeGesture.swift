//
//  ShakeGesture.swift
//  CalcuApp
//
//  Created by Ramiro Nehuen Sanabria on 18/10/2025.
//

import SwiftUI
import UIKit

// La notificación que enviaremos cuando ocurra un gesto de sacudir.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

// Sobrescribimos el comportamiento por defecto del gesto para que envíe nuestra notificación.
extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

// Un modificador de vista que detecta la sacudida y ejecuta una acción.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// Una extensión de View para que el modificador sea más fácil de usar.
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}
