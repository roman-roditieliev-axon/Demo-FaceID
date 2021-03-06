//
//  BiometricAuthManager.swift
//  Demo-FaceID
//
//  Created by User on 14.07.2021.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class BiometricAuthManager: ObservableObject {

    @Published var successBiometric: Bool?
    let context = LAContext()
    var loginReason = "Logging in with Face ID"


    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            fatalError()
        }
    }

    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    func authenticateUser(completion: @escaping (String) -> Void) {
        guard canEvaluatePolicy() else {
            completion("Face ID not available")
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    self.successBiometric = true
                }
            } else {
                let message: String

                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity."
                case LAError.userCancel?:
                    message = "You pressed cancel."
                case LAError.userFallback?:
                    message = "You pressed password."
                case LAError.biometryNotAvailable?:
                    message = "Face ID/Touch ID is not available."
                case LAError.biometryNotEnrolled?:
                    message = "Face ID/Touch ID is not set up."
                case LAError.biometryLockout?:
                    message = "Face ID/Touch ID is locked."
                default:
                    message = "Face ID/Touch ID may not be configured"
                }
                completion(message)
            }
        }
    }
}
