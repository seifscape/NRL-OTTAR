//
//  Capture.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 6/30/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import Foundation
//
//struct Capture:Decodable {
//    let note:Note
//    let photos:[Photo?]
//}

// MARK: - Captures
struct Captures: Codable {
    let captures: [Capture]?
    let albumID: Int?
    let annotation, coordinates, dateCreated, dateUpdated: String?
    let images: [Image]?

    enum CodingKeys: String, CodingKey {
        case captures
        case albumID = "album_id"
        case annotation, coordinates
        case dateCreated = "date_created"
        case dateUpdated = "date_updated"
        case images
    }
}

// MARK: - Capture
struct Capture: Codable {
    let albumID: Int
    let annotation, coordinates, dateCreated, dateUpdated: String

    enum CodingKeys: String, CodingKey {
        case albumID = "album_id"
        case annotation, coordinates
        case dateCreated = "date_created"
        case dateUpdated = "date_updated"
    }
}

// MARK: - Image
struct Image: Codable {
    let imageID: Int
    let encoded, dateCreated: String

    enum CodingKeys: String, CodingKey {
        case imageID = "image_id"
        case encoded
        case dateCreated = "date_created"
    }
}
