/*
 * Copyright (c) 2024 AUTHADA GmbH
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */

//
//  WalletDocument+Extensions.swift
//

import Foundation
import SwiftUI

public extension WalletDocument {
    
    func getExpiryDate(parser: (String) -> String) -> String? {
      if let expiryDate = expiryDateValue() {
        return parser(expiryDate)
      } else {
        return nil
      }
    }

    func hasExpired(parser: (String) -> Date?) -> Bool {
      guard let value = expiryDateValue(), let expiryDate = parser(value) else {
        return false
      }
      return expiryDate < Date.now
    }
        
    func getPortrait() -> Image? {
        var image: Image?
        
        if let portraitImageData = self.getPortraitImageData(), let uiImage = UIImage(data: portraitImageData) {
            image = Image(uiImage: uiImage)
        }
        
        return image
    }
    
}
