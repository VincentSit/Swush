//
//  APNSService.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import Foundation

class APNSService: NSObject {
    private var session: URLSession?
    private var identity: SecIdentity?
    
    func sendPush(for apns: APNS) async throws -> String? {
        if case .keychain(let identity) = apns.certificateType {
            self.identity = identity
        }
       
        switch apns.certificateType {
        case .keychain:
            session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        case .p8:
            session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        }
        guard let session = session else { return nil }

        var request = URLRequest(
            url: URL(
                string:
                "https://api.\(apns.isSandbox ? "development." : "")push.apple.com/3/device/\(apns.deviceToken)"
            )!)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: apns.payload!)

        if case .p8 = apns.certificateType {
            request.addValue("bearer \(apns.jwt)", forHTTPHeaderField: "authorization")
        }
        request.addValue(apns.topic, forHTTPHeaderField: "apns-topic")
        request.addValue(String(apns.priority.rawValue), forHTTPHeaderField: "apns-priority")
        request.addValue(apns.payloadType.rawValue, forHTTPHeaderField: "apns-push-type")
        if !apns.collapseId.isEmpty {
            request.addValue(apns.collapseId, forHTTPHeaderField: "apns-collapse-id")
        }
        if !apns.notificationId.isEmpty {
            request.addValue(apns.notificationId, forHTTPHeaderField: "apns-notification-id")
        }
        if !apns.expiration.isEmpty {
            request.addValue(apns.expiration, forHTTPHeaderField: "apns-expiration")
        }

        let (data, response) = try await session.data(for: request)
        guard let status = response.status else { fatalError() }
        if !(200...299).contains(status) {
            var apnsError: APNSError? = nil
            do {
                apnsError = try JSONDecoder().decode(APNSError.self, from: data)
            } catch {
                print("Unable to decode error: \(error)")
            }
            if let apnsError = apnsError { throw apnsError.apiError }
            return nil
        } else {
            guard let res = response as? HTTPURLResponse else { return nil }
            print(res.allHeaderFields)
            return res.allHeaderFields["apns-id"] as? String
        }
    }
}

extension APNSService: URLSessionDelegate {
    func urlSession(_: URLSession, didReceive _: URLAuthenticationChallenge) async
        -> (URLSession.AuthChallengeDisposition, URLCredential?)
    {
        guard let identity = identity else { return (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)}
        var certificate: SecCertificate?
        SecIdentityCopyCertificate(identity, &certificate)
        let cred = URLCredential(
            identity: identity, certificates: [certificate!], persistence: .forSession
        )
        return (URLSession.AuthChallengeDisposition.useCredential, cred)
    }
}
