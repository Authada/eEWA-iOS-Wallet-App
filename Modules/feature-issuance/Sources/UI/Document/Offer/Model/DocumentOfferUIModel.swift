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
import logic_business
import logic_resources

public struct DocumentOfferUIModel: Sendable {
    
    @EquatableNoop
    public var id: String
    
    public let issuerName: String
    public let txCode: TxCode?
    public let uiOffers: [UIOffer]
    public let docOffers: [OfferedDocModel]
    public let isValidated: Bool
    
    public init(
        id: String = UUID().uuidString,
        issuerName: String,
        txCode: TxCode?,
        uiOffers: [UIOffer],
        docOffers: [OfferedDocModel],
        isValidated: Bool
    ) {
        self.id = id
        self.issuerName = issuerName
        self.txCode = txCode
        self.uiOffers = uiOffers
        self.docOffers = docOffers
        self.isValidated = isValidated
    }
}

public extension DocumentOfferUIModel {
    struct UIOffer: Identifiable, Sendable {
        
        @EquatableNoop
        public var id: String
        
        public let documentName: String
        public let documentType: DocumentTypeIdentifier
        
        public init(
            id: String = UUID().uuidString,
            documentName: String,
            documentType: DocumentTypeIdentifier
        ) {
            self.id = id
            self.documentName = documentName
            self.documentType = documentType
        }
    }
}

public extension DocumentOfferUIModel {
  struct TxCode: Sendable {

    let isRequired: Bool
    let codeLenght: Int

    public init(isRequired: Bool, codeLenght: Int) {
      self.isRequired = isRequired
      self.codeLenght = codeLenght
    }
  }
}

public extension DocumentOfferUIModel {
    static func mock() -> DocumentOfferUIModel {
        return .init(
            id: UUID().uuidString,
            issuerName: LocalizableString.shared.get(with: .unknownIssuer),
            txCode: nil,
            uiOffers: [
                .init(
                    id: UUID().uuidString,
                    documentName: "Document Name",
                    documentType: .GENERIC(docType: "")
                ),
                .init(
                    id: UUID().uuidString,
                    documentName: "Document Name",
                    documentType: .GENERIC(docType: "")
                ),
                .init(
                    id: UUID().uuidString,
                    documentName: "Document Name",
                    documentType: .GENERIC(docType: "")
                ),
                .init(
                    id: UUID().uuidString,
                    documentName: "Document Name",
                    documentType: .GENERIC(docType: "")
                ),
                .init(
                    id: UUID().uuidString,
                    documentName: "Document Name",
                    documentType: .GENERIC(docType: "")
                )
            ],
            docOffers: [],
            isValidated: false
        )
    }
}

extension OfferedIssuanceModel {
    func transformToDocumentOfferUi() -> DocumentOfferUIModel {
        return self.docModels.transformToDocumentOfferUi(
            codeRequired: self.isTxCodeRequired,
            codeLength: self.txCodeSpec?.length ?? 0,
            isValidated: self.isValidated
        )
    }
}

private extension Array where Element == OfferedDocModel {
    func transformToDocumentOfferUi(
        codeRequired: Bool,
        codeLength: Int,
        isValidated: Bool
    ) -> DocumentOfferUIModel {
        var issuer: String = LocalizableString.shared.get(with: .unknownIssuer)
        var offers: [DocumentOfferUIModel.UIOffer] = []
        
        self.forEach { doc in
            issuer = doc.issuerName
            offers.append(
                .init(
                    documentName: doc.displayName,
                    documentType: DocumentTypeIdentifier(rawValue: doc.docType)
                )
            )
        }
        
        return .init(
            issuerName: issuer,
            txCode: codeRequired ? .init(isRequired: codeRequired, codeLenght: codeLength): nil,
            uiOffers: offers,
            docOffers: self,
            isValidated: isValidated
        )
    }
}
