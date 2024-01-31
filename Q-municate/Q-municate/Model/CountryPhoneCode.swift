//
//  CountryCode.swift
//  Q-municate
//
//  Created by Injoit on 11.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

struct CountryPhoneCodeConstant {
    static let base : UInt32 = 127397
}

class CountryPhoneCode: Hashable, Codable, Identifiable {
    var id: String {
        return code
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
    static func == (lhs: CountryPhoneCode, rhs: CountryPhoneCode) -> Bool {
        if lhs.code == rhs.code { return true}
        return false
    }
    
    static var defaultCountryPhoneCode: CountryPhoneCode {
        return CountryPhoneCode(name: "United States",
                                dial_code: "+1",
                                code: "US")
    }
    
    static func getCodes() -> [CountryPhoneCode] {
        var countryPhoneCodes: [CountryPhoneCode] = []
        if let path = Bundle.main.url(forResource: "PhoneCountryCodes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: path, options: .alwaysMapped)
                let codes = try JSONDecoder().decode([CountryPhoneCode].self, from: data)
                countryPhoneCodes.append(contentsOf: codes)
                
            } catch let error {
                print("Get Country Codes error: \(error.localizedDescription)")
            }
        }
        return countryPhoneCodes
    }
    
    var name: String
    var dial_code: String
    var code: String
    
    init(name: String, dial_code: String, code: String) {
        self.name = name
        self.dial_code = dial_code
        self.code = code
    }
    
    var flag: String {
        code
            .unicodeScalars
            .map({ CountryPhoneCodeConstant.base + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
}
