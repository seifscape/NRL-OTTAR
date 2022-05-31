//
//  Rest.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 5/30/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import Foundation
import Get

class InspectorMinesNetworkAPI {

    static let sharedInstance = InspectorMinesNetworkAPI()
    private init() {} //This prevents others from using the default '()' initializer for this class.

    var client = APIClient(baseURL: URL(string: "http://127.0.0.1:1111")) { configuration in
        configuration.delegate = InspectorMinesClientDelegate(apiKey: "nrl_ottar_2022")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
//        encoder.keyEncodingStrategy = .convertToSnakeCase

        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        configuration.encoder = encoder
        configuration.decoder = decoder
    }
}

