//
//  OTTARClientDelegate.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 5/29/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import Get
import Foundation
import os.log


actor OTTARClientDelegate: APIClientDelegate {
  private let logger: Logger?
  private let apiKey: String

  init(
    logger: Logger? = nil,
    apiKey: String
  ) {
    self.logger = logger
    self.apiKey = apiKey
  }

  func client(_ client: APIClient, willSendRequest request: inout URLRequest) async throws {
    request.setValue(apiKey, forHTTPHeaderField: "Authorization")
  }

  func shouldClientRetry(_ client: APIClient, withError error: Error) async throws -> Bool {
    guard case .unacceptableStatusCode(401) = error as? APIError else {
      return false
    }

    self.logger?.info("Retrying after error: \(error.localizedDescription)")

    return true
  }

  nonisolated func client(_ client: APIClient, didReceiveInvalidResponse response: HTTPURLResponse, data: Data) -> Error {
    let networkError = NetworkError(
      url: response.url,
      headers: response.allHeaderFields,
      statusCode: response.statusCode,
      payload: data
    )

    self.logger?.error("Failed request with error: \(networkError.localizedDescription)")

    return networkError
  }
}
