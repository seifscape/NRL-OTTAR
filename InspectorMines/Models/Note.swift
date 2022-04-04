//
//  Note.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 6/30/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import Foundation

struct Note:Decodable {
    let title:String
    let description:String
    let capturedTime:Date
}

