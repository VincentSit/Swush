//
//  AppState.swift
//  Swush
//
//  Created by Quentin Eude on 01/02/2022.
//

import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    enum CertificateType {
        case keychain, p8
    }
    
    // MARK: Sidebar

    @Published var showDeleteAlert: Bool = false
    @Published var apnsToDelete: APNS? = nil

    @Published var apnsToRename: APNS? = nil
    @Published var newName: String = ""

    @Published var canCreateNewApns: Bool = true
    @Published var canRenameApns: Bool = true

    @Published var selectedApns: APNS? = nil {
        didSet {
            if let apns = selectedApns, oldValue != selectedApns {
                setApns(apns)
            }
        }
    }

    // MARK: APNS form

    @Published var selectedCertificateType: APNS.CertificateType = .keychain(certificate: nil) {
        didSet {
            didChangeCertificateType()
        }
    }

    @Published var name: String = ""
    @Published var selectedIdentityType: APNS.IdentityType = .sandbox
    @Published var deviceToken = ""
    @Published var payload =
        "{\n\t\"aps\": {\n\t\t\"alert\": \"Push test!\",\n\t\t\"sound\": \"default\",\n\t}\n}"
    @Published var topics: [String] = []
    @Published var priority: APNS.Priority = .high
    @Published var selectedTopic: String = ""
    @Published var showCertificateTypePicker: Bool = false
    @Published var selectedPayloadType: APNS.PayloadType = .alert
    @Published var collapseId: String = ""
    @Published var notificationId: String = ""
    @Published var expiration: String = ""
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var shouldAlertPresented: Bool = false
    @Published var alertPresentState: AlertPresentType = .none {
        didSet {
            shouldAlertPresented = alertPresentState.shouldPresent
            alertTitle = alertPresentState.content.title
            alertMessage = alertPresentState.content.message
        }
    }
    
    
    var canSendApns: Bool {
        return !deviceToken.isEmpty && !payload.isEmpty && !selectedTopic.isEmpty && !selectedCertificateType.isEmptyOrNil
    }
    
    private func setApns(_ apns: APNS) {
        selectedCertificateType = apns.certificateType
        selectedIdentityType = apns.isSandbox ? .sandbox : .production
        deviceToken = apns.deviceToken
        payload = apns.rawPayload
        topics = apns.topics 
        priority = apns.priority
        selectedTopic = apns.topic
        selectedPayloadType = apns.payloadType
        name = apns.name
        didChangeCertificateType()
    }

    private func didChangeCertificateType() {
        switch selectedCertificateType {
            case .p8(let filepath, let teamId, let keyId): didChange(filepath: filepath, teamId: teamId, keyId: keyId)
            case .keychain(let certificate): didChange(identity: certificate)
        }
    }
    
    private func didChange(filepath: String, teamId: String, keyId: String) {
        showCertificateTypePicker = true
    }
    
    private func didChange(identity: SecIdentity?) {
        guard let identity = identity else {
            topics = []
            return
        }
        let type = identity.type
        switch type {
        case .universal:
            showCertificateTypePicker = true
        case .production:
            selectedIdentityType = .production
        default:
            break
        }

        topics = identity.topics
        selectedTopic = topics.first ?? ""
    }

    func selectionBindingForId(apns: APNS?) -> Binding<Bool> {
        Binding<Bool> { () -> Bool in
            self.selectedApns?.id == apns?.id
        } set: { newValue in
            if newValue {
                self.selectedApns = apns
            }
        }
    }
}
