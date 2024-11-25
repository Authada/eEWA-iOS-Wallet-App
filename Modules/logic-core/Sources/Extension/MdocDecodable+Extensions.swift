/*
 * Copyright (c) 2023 European Commission
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
 *
 * Modified by AUTHADA GmbH August 2024
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
import SwiftUI
import logic_resources

public extension MdocDecodable {

  func getDrivingPrivileges(parser: (String) -> String) -> NameValue? {
    guard
      let mdl = self as? IsoMdlModel,
      let drivingPrivileges = mdl.drivingPrivileges
    else {
      return nil
    }

    return NameValue(
      name: IsoMdlModel.CodingKeys.drivingPrivileges.rawValue,
      value: String(drivingPrivileges.drivingPrivileges
        .reduce(into: "", { partialResult, privilege in
          guard
            let issueDate = privilege.issueDate,
            let expiryDate = privilege.expiryDate
          else {
            return
          }
          partialResult +=  """
                            \(LocalizableString.shared.get(with: .vehicleCategory)): \(privilege.vehicleCategoryCode)
                            \(LocalizableString.shared.get(with: .dateOfIssue)): \(parser(issueDate))
                            \(LocalizableString.shared.get(with: .dateOfExpiry)): \(parser(expiryDate))

                            """
        })
          .dropLast()),
      order: IsoMdlModel.CodingKeys.allCases.firstIndex(of: .drivingPrivileges) ?? .max
    )
  }
}
