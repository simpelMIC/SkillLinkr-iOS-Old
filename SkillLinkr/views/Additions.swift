//
//  Additions.swift
//  SkillLinkr
//
//  Created by Christian on 22.07.24.
//

import Foundation
import SwiftUI

struct OptionalTextField: View {
    let placeHolder: String
    @Binding var text: String?
    
    init(_ placeHolder: String, text: Binding<String?>) {
        self.placeHolder = placeHolder
        self._text = text
    }

    var body: some View {
        TextField(
            placeHolder,
            text: Binding(
                get: { text ?? "" },
                set: {
                    text = $0.isEmpty ? nil : $0
                }
            )
        )
    }
}

struct OptionalToggle: View {
    let placeHolder: String
    @Binding var isOn: Bool?
    
    init(_ placeHolder: String, isOn: Binding<Bool?>) {
        self.placeHolder = placeHolder
        self._isOn = isOn
    }

    var body: some View {
        Toggle(
            placeHolder,
            isOn: Binding(
                get: { isOn ?? false },
                set: { newValue in
                    isOn = newValue ? true : nil
                }
            )
        )
    }
}

struct OptionalCountryPicker: View {
    @Binding var selectedCountry: String?

    var body: some View {
        VStack {
            Picker(selection: $selectedCountry, label: Text("Select Country")) {
                Text("-").tag(String?.none)
                ForEach(NSLocale.isoCountryCodes, id: \.self) { countryCode in
                    HStack {
                        Text(countryFlag(countryCode))
                        Text(Locale.current.localizedString(forRegionCode: countryCode) ?? "")
                    }.tag(String?.some(countryCode))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
        }
        .padding()
    }

    private var selectedCountryText: String {
        if let code = selectedCountry {
            return Locale.current.localizedString(forRegionCode: code) ?? ""
        } else {
            return "None"
        }
    }

    func countryFlag(_ countryCode: String) -> String {
        String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap {
            UnicodeScalar(127397 + $0.value)
        }))
    }
}

struct CountryPicker: View {
    @Binding var selectedCountry: String

    var body: some View {
        VStack {
            Picker(selection: $selectedCountry, label: Text("Select Country")) {
                ForEach(NSLocale.isoCountryCodes, id: \.self) { countryCode in
                    HStack {
                        Text(countryFlag(countryCode))
                        Text(Locale.current.localizedString(forRegionCode: countryCode) ?? "")
                    }.tag(countryCode)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
        }
        .padding()
    }

    func countryFlag(_ countryCode: String) -> String {
        String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap {
            UnicodeScalar(127397 + $0.value)
        }))
    }
}

struct CountryList: View {
    var body: some View {
        ForEach(NSLocale.isoCountryCodes, id: \.self) { item in
            HStack {
                Text(countryFlag(item))
                Text(Locale.current.localizedString(forRegionCode: item) ?? "")
            }
        }
    }
    
    func countryFlag(_ countryCode: String) -> String {
        String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap {
            UnicodeScalar(127397 + $0.value)
        }))
    }
}
