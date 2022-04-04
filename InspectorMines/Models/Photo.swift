//
//  Photo.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 6/30/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import Foundation
import UIKit

struct Photo:Decodable {
    let photo:CaptureImage
    let capturedTime:Date
}

// https://stackoverflow.com/questions/46197785/how-to-conform-uiimage-to-codable
public struct CaptureImage: Codable {

    public let photo: Data
    
    public init(photo: UIImage) {
        self.photo = photo.pngData()!
    }
}
