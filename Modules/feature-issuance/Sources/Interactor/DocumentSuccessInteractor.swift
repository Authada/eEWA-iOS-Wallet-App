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
import logic_core
import logic_business
import logic_resources
import SwiftUI

public protocol DocumentSuccessInteractor {
    func getMainDisplayValue(for documentIdentifier: String) -> String?
    func getDocumentSuccessCaption(for documentIdentifier: String) -> LocalizableString.Key?
    func getDocumentTypeName(for documentIdentifier: String) -> String?
    func getDocumentSymbol(for documentIdentifier: String) -> Image?
}

final class DocumentSuccessInteractorImpl: DocumentSuccessInteractor {
    
    private let walletController: WalletKitController
    
    init(walletController: WalletKitController ) {
        self.walletController = walletController
    }
    
    public func getMainDisplayValue(for documentIdentifier: String) -> String? {
        
        guard let document = walletController.fetchDocument(with: documentIdentifier) else {
            return nil
        }
        var documentMainValue :String? = nil
        if let bearerName = document.getBearersName() {
            documentMainValue = "\(bearerName.first) \(bearerName.last)"
        }
        else {
            if let displayString = document.displayStrings.sorted(by: {$0.order < $1.order}).first{
                documentMainValue = displayString.value
            }
            
        }
        return documentMainValue
    }
    
    public func getDocumentSuccessCaption(for documentIdentifier: String) -> LocalizableString.Key? {
        guard
            let type = walletController.fetchDocument(with: documentIdentifier)?.docTypes.first
        else {
            return nil
        }
        return .issuanceSuccessCaption([DocumentTypeIdentifier(rawValue: type).localizedTitle])
    }
    
    public func getDocumentTypeName(for documentIdentifier: String) -> String? {
        guard
            let type = walletController.fetchDocument(with: documentIdentifier)?.docTypes.first
        else {
            return nil
        }
        return DocumentTypeIdentifier(rawValue: type).localizedTitle
    }
    
    public func getDocumentSymbol(for documentIdentifier: String) -> Image? {
        guard
            let type = walletController.fetchDocument(with: documentIdentifier)?.docTypes.first
        else {
            return nil
        }
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
