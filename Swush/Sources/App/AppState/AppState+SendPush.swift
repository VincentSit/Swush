//
//  AppState+Send.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import Foundation

extension AppState {
    func sendPush() async {
        guard let _ = payload.toJSON() else {
            alertPresentState = .error(message: "Please provide a valid JSON payload.")
            return
        }
        switch selectedCertificateType {
        case .p8(let filename, _, _):
            if !FileManager.default.fileExists(atPath: filename) {
                alertPresentState = .error(message: "Please provide a valid .p8 token.")
                return
            }
        case .keychain: break
        }
        let apns = APNS(
            name: name,
            creationDate: selectedApns?.creationDate ?? Date(),
            updateDate: selectedApns?.updateDate ?? Date(),
            certificateType: selectedCertificateType,
            rawPayload: payload,
            deviceToken: deviceToken,
            topic: selectedTopic,
            payloadType: selectedPayloadType,
            priority: priority,
            isSandbox: selectedIdentityType == .sandbox,
            collapseId: collapseId,
            notificationId: notificationId,
            expiration: expiration
        )
        do {
            let apnsId = try await DependencyProvider.apnsService.sendPush(for: apns)
            if let apnsId = apnsId {
                alertPresentState = .success(message: "Send successfully, apns-id is \(apnsId).")
            }
        } catch let error as APNSService.APIError {
            print(error)
            alertPresentState = .error(message: error.description)
        } catch {
            print(error)
        }
        
    }
    
    private func sendPushWithApnsToken() {
        
    }
    
    private func sendPushWithApnsCertificate() {
        
    }
}
