//
//  Capture.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 6/30/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import Foundation

struct Capture:Decodable {
    let note:Note
    let photos:[Photo?]
}
