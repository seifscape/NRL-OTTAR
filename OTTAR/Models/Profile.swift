//
//  Profile.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 6/30/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import Foundation

struct Profile:Decodable {
    let profileName:String
    let captures:[Capture]
}
