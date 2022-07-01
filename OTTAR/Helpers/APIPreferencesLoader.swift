//
//  Configuration.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 6/17/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import Foundation

struct APIPreferences: Codable {
  var apiKey: String
  var baseURL: String
}

class APIPreferencesLoader {
    static private var plistURL: URL {
      let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      return documents.appendingPathComponent("ApiPreferences.plist")
    }

  static func load() -> APIPreferences {
    let decoder = PropertyListDecoder()

      guard let data = try? Data.init(contentsOf: plistURL),
      let preferences = try? decoder.decode(APIPreferences.self, from: data)
      else { return APIPreferences(apiKey: "nrl_ottar_2022", baseURL: "") }

    return preferences
  }

    static func write(preferences: APIPreferences) {
      let encoder = PropertyListEncoder()

      if let data = try? encoder.encode(preferences) {
        if FileManager.default.fileExists(atPath: plistURL.path) {
          // Update an existing plist
            try? data.write(to: plistURL)
        } else {
          // Create a new plist
          FileManager.default.createFile(atPath: plistURL.path, contents: data, attributes: nil)
        }
      }
    }

    static func copyPreferencesFromBundle() {
      if let path = Bundle.main.path(forResource: "ApiPreferences", ofType: "plist"),
        let data = FileManager.default.contents(atPath: path),
        FileManager.default.fileExists(atPath: plistURL.path) == false {
        FileManager.default.createFile(atPath: plistURL.path, contents: data, attributes: nil)
      }
    }
}


final class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let BaseURL = "kBaseURL"
    }

    class func getBaseURL() -> String? {
        return UserDefaults.standard.string(forKey: SettingsBundleKeys.BaseURL)
    }

    class func setBaseURL() {
        UserDefaults.standard.set(APIPreferencesLoader.load().baseURL, forKey: SettingsBundleKeys.BaseURL)
    }
}
