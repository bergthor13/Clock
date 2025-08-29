//
//  InsecureSe.swift
//  Clock
//
//  Created by Bergþór Þrastarson on 6.3.2025.
//  Copyright © 2025 Bergþór Þrastarson. All rights reserved.
//

import Foundation

class InsecureSessionDelegate: NSObject, URLSessionDelegate {
    // This delegate method allows you to override the default SSL trust evaluation.
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Ensure there is a valid server trust object
        if let serverTrust = challenge.protectionSpace.serverTrust {
            // Create a credential from the server trust and use it
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Cancel the authentication challenge if there's no trust information
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
