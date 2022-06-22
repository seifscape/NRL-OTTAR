//
//  Rest.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 5/30/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import Foundation
import Get

class OTTARNetworkAPI {

    static let sharedInstance = OTTARNetworkAPI()
    private init() {} //This prevents others from using the default '()' initializer for this class.


    var client = APIClient(baseURL: URL(string: APIPreferencesLoader.load().baseURL)) { configuration in
        configuration.delegate = OTTARClientDelegate(apiKey: APIPreferencesLoader.load().apiKey)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        configuration.encoder = encoder
        configuration.decoder = decoder
    }

    func updateClient() {
        client = APIClient(baseURL: URL(string: APIPreferencesLoader.load().baseURL)) { configuration in
            configuration.delegate = OTTARClientDelegate(apiKey: APIPreferencesLoader.load().apiKey)
        }
    }
}

