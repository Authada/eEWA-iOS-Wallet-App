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
import Foundation
import logic_core
import logic_resources
import logic_business
import SwiftUI

public struct DocumentUIModel: Identifiable, Equatable {

  @EquatableNoop
  public var id: String

  public let value: Value

  public init(id: String, value: Value) {
    self.id = id
    self.value = value
  }
}

public extension DocumentUIModel {

  struct Value: Equatable {

    @EquatableNoop
    public var id: String

    public let type: String
    public let docFormat: DataFormat?
    public let title: String
    public var createdAt: Date
    public let expiresAt: String?
    public let hasExpired: Bool
      
      public var icon: Image {
          let docType = DocumentTypeIdentifier(rawValue: type)
          switch docType {
          case .PID:
              return Theme.shared.image.ident
          case .MDL:
              return Theme.shared.image.ic_eaa_mdl
          case .EMAIL:
              return Theme.shared.image.ic_eaa_email
          default:
              return Theme.shared.image.ic_eaa_generic
          }
      }
  }
  static func proxy()-> DocumentUIModel {
      .init(
        id: ProxyPidDocument.proxyTagID,
        value: .init(
          id: ProxyPidDocument.proxyTagID,
          type: DocumentManager.euPidDocTypeMdoc,
          docFormat: nil,
          title: LocalizableString.shared.get(with: .identify),
          createdAt: Date(),
          expiresAt: LocalizableString.shared.get(with: .moreAboutThisFunction),
          hasExpired: false
        )
      )
  }
  static func mocks() -> [DocumentUIModel] {
    [
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Digital ID",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "EUDI Conference",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Passport",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Document 1",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Document 2",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Document 3",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Document 4",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Document 5",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Document 6",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      ),
      .init(
        id: UUID().uuidString,
        value: .init(
          id: UUID().uuidString,
          type: UUID().uuidString,
          docFormat: nil,
          title: "Passport",
          createdAt: Date(),
          expiresAt: "22/01/2025",
          hasExpired: false
        )
      )
    ]
  }
}

extension Array where Element == WalletDocument {
  func transformToDocumentUi() -> [DocumentUIModel] {
    self.map { item in
        if item.id == "proxy" {
            return .proxy()
        }
      return .init(
        id: UUID().uuidString,
        value: .init(
          id: item.id,
          type: item.docTypes.first ?? "",
          docFormat: item.docFormat,
          title: DocumentTypeIdentifier(rawValue: item.docTypes.first ?? "").localizedTitle,
          createdAt: item.createdAt,
          expiresAt: item.getExpiryDate(
            parser: {
              Locale.current.localizedDateTime(
                date: $0,
                uiFormatter: "dd MMM yyyy"
              )
            }
          ),
          hasExpired: item.hasExpired(
            parser: { Locale.current.parseDate(date: $0) }
          )
        )
      )
    }
  }
}
