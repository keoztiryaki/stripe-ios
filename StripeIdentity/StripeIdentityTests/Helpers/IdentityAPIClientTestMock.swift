//
//  IdentityAPIClientTestMock.swift
//  StripeIdentityTests
//
//  Created by Mel Ludowise on 11/4/21.
//

import Foundation
@_spi(STP) import StripeCore
@testable import StripeIdentity

final class IdentityAPIClientTestMock: IdentityAPIClient {

    let verificationPage = MockAPIRequests<String, VerificationPage>()
    let verificationSessionData = MockAPIRequests<(id: String, data: VerificationSessionDataUpdate, ephemeralKey: String), VerificationSessionData>()

    func postIdentityVerificationPage(clientSecret: String) -> Promise<VerificationPage> {
        return verificationPage.makeRequest(with: clientSecret)
    }

    func postIdentityVerificationSessionData(
        id: String,
        updating verificationData: VerificationSessionDataUpdate,
        ephemeralKeySecret: String
    ) -> Promise<VerificationSessionData> {
        return verificationSessionData.makeRequest(with: (
            id: id,
            data: verificationData,
            ephemeralKey: ephemeralKeySecret
        ))
    }
}

class MockAPIRequests<ParamsType, ResponseType> {
    private var requests: [Promise<ResponseType>] = []
    private(set) var requestHistory: [ParamsType] = []

    fileprivate func makeRequest(with params: ParamsType) -> Promise<ResponseType> {
        requestHistory.append(params)
        let promise = Promise<ResponseType>()
        requests.append(promise)
        return promise
    }

    func respondToRequests(with result: Result<ResponseType, Error>) {
        requests.forEach { promise in
            promise.fullfill(with: result)
        }
    }
}