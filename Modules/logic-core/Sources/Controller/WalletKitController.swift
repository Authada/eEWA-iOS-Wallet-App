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
import Combine
import logic_resources
import logic_business

public protocol WalletKitController {

  var wallet: EudiWallet { get }
  var activeCoordinator: PresentationSessionCoordinator? { get }

  func startProximityPresentation() async -> PresentationSessionCoordinator
  func startSameDevicePresentation(deepLink: URLComponents) async -> PresentationSessionCoordinator
  func startCrossDevicePresentation(urlString: String) async -> PresentationSessionCoordinator
  func stopPresentation()
  func fetchDocuments() -> [WalletDocument]
  func fetchDocuments(with type: DocumentTypeIdentifier) -> [WalletDocument]
  func fetchDocuments(excluded: [DocumentTypeIdentifier]) -> [WalletDocument]
  func fetchMainPidDocument() -> WalletDocument?
  func fetchDocument(with id: String) -> WalletDocument?
  func loadSampleData(dataFiles: [String]) async throws
  func clearDocuments() async throws
  func deleteDocument(with id: String) async throws
  func loadDocuments() async throws
  func issueDocument(docType: String, format: DataFormat) async throws -> WalletStorage.Document
  func resolveOfferUrlDocTypes(uriOffer: String) async throws -> OfferedIssuanceModel
  func issueDocumentsByOfferUrl(
    offerUri: String,
    docTypes: [OfferedDocModel],
    txCodeValue: String?
  ) async throws -> [WalletStorage.Document]
  func valueForElementIdentifier(
    for documentType: DocumentTypeIdentifier,
    with documentId: String,
    elementIdentifier: String,
    parser: (String) -> String
  ) -> MdocValue
  func mandatoryFields(for documentType: DocumentTypeIdentifier) -> [String]
}

final class WalletKitControllerImpl: WalletKitController {
    
  public let wallet = EudiWallet.standard

  public private(set) var activeCoordinator: PresentationSessionCoordinator?

  private let configLogic: WalletKitConfig
  private var cancellables = Set<AnyCancellable>()

  init(configLogic: WalletKitConfig) {
    self.configLogic = configLogic
    wallet.userAuthenticationRequired = configLogic.userAuthenticationRequired
    wallet.verifierApiUri = configLogic.verifierConfig.apiUri
    wallet.verifierLegalName = configLogic.verifierConfig.legalName
    wallet.openID4VciIssuerUrl = configLogic.vciConfig.issuerUrl
    wallet.openID4VciClientId = configLogic.vciConfig.clientId
    wallet.openID4VciRedirectUri = configLogic.vciConfig.redirectUri
    wallet.trustedReaderCertificates = configLogic.proximityConfig.trustedCerts
    wallet.walletAttestationHostUrl = configLogic.walletAttestationConfig.hostUrl
    wallet.walletAttestationClientId = configLogic.walletAttestationConfig.clientId
    wallet.externalURLService = ExternalAppHandler()
    wallet.issuerCertChainData = configLogic.vciConfig.issuerCertChainData
  }

  func resolveOfferUrlDocTypes(uriOffer: String) async throws -> OfferedIssuanceModel {
      let offermodel = try await wallet.resolveOfferUrlDocTypes(uriOffer: uriOffer)
      return offermodel
  }

  func issueDocumentsByOfferUrl(
    offerUri: String,
    docTypes: [OfferedDocModel],
    txCodeValue: String?
  ) async throws -> [WalletStorage.Document] {
    return try await wallet.issueDocumentsByOfferUrl(
      offerUri: offerUri,
      docTypes: docTypes,
      txCodeValue: txCodeValue
    )
  }

  public func loadSampleData(dataFiles: [String]) async throws {
    return try await wallet.loadSampleData(sampleDataFiles: dataFiles)
  }

  public func clearDocuments() async throws {
    return try await wallet.deleteDocuments()
  }

  public func deleteDocument(with id: String) async throws {
    return try await wallet.storage.deleteDocument(id: id)
  }

  public func loadDocuments() async throws {
    _ = try await wallet.loadDocuments()
  }

    public func startProximityPresentation() async -> PresentationSessionCoordinator {
    self.stopPresentation()
        let session = await wallet.beginPresentation(flow: .ble)
    let presentationSessionCoordinator = DIGraph.resolver.force(
      PresentationSessionCoordinator.self,
      name: RegistrationName.proximity.rawValue,
      argument: session
    )
    self.activeCoordinator = presentationSessionCoordinator
    presentationSessionCoordinator.onSuccess {
      stopPresentation()
    }
    return presentationSessionCoordinator
  }

    public func startSameDevicePresentation(deepLink: URLComponents) async -> PresentationSessionCoordinator {
        await self.startRemotePresentation(
      urlString: decodeDeeplink(
        link: deepLink
      ) ?? ""
    )
  }

    public func startCrossDevicePresentation(urlString: String) async -> PresentationSessionCoordinator {
        await self.startRemotePresentation(urlString: urlString)
  }

    private func startRemotePresentation(urlString: String) async -> PresentationSessionCoordinator {
    self.stopPresentation()

    let data = urlString.data(using: .utf8) ?? Data()

    let session = await wallet.beginPresentation(flow: .openid4vp(qrCode: data))
    let presentationSessionCoordinator = DIGraph.resolver.force(
      PresentationSessionCoordinator.self,
      name: RegistrationName.remote.rawValue,
      argument: session
    )
    self.activeCoordinator = presentationSessionCoordinator
    presentationSessionCoordinator.onSuccess {
      stopPresentation()
    }
    return presentationSessionCoordinator
  }

  public func stopPresentation() {
    self.cancellables.forEach {$0.cancel()}
    self.activeCoordinator = nil
  }

  public func fetchDocuments() -> [WalletDocument] {
    return wallet.storage.walletDocuments
  }

  public func fetchDocuments(with type: DocumentTypeIdentifier) -> [WalletDocument] {
    return wallet.storage.walletDocuments
      .filter({ $0.docTypes.contains(type.rawValue) })
  }

  func fetchMainPidDocument() -> WalletDocument? {
    return fetchDocuments(with: DocumentTypeIdentifier.PID)
      .sorted { $0.createdAt > $1.createdAt }.last
  }

  func fetchDocuments(excluded: [DocumentTypeIdentifier]) -> [any WalletDocument] {
    let excludedRawValues = excluded.map { $0.rawValue }
    return fetchDocuments().filter {
          for docType in $0.docTypes {
              if excludedRawValues.contains(docType) {
                  return false
              }
          }
          return true
      }
  }

  public func fetchDocument(with id: String) -> WalletDocument? {
    wallet.storage.getWalletDocument(id: id)
  }

  public func issueDocument(docType: String, format: DataFormat) async throws -> WalletStorage.Document {
    return try await wallet.issueDocument(docType: docType, format: format)
  }

  private func decodeDeeplink(link: URLComponents) -> String? {
    // Handling requests of the form
    //    mdoc-openid4vp://https://eudi.netcompany-intrasoft.com?client_id=Verifier&request_uri=https://eudi.netcompany-intrasoft.com/wallet/request.jwt/OWB1_xVU7ndoHmirBn7S2JpcC5fFPzAXGCY1fTLxDjczVATjzQvre_w4yEcMB4FO5KwuyYXXw-JottarKgEvRQ
    // so we need to drop scheme and forward slashes and keep the rest of the url in order to
    // pass to wallet

    return link.removeSchemeFromComponents()?.string
  }
}

extension WalletKitController {

  // TODO: Mandatory fields should be returned in a generic model
  public func mandatoryFields(for documentType: DocumentTypeIdentifier) -> [String] {
    switch documentType {
    case .PID:
      return [
        "issuance_date",
        "expiry_date",
        "issuing_authority",
        "document_number",
        "administrative_number",
        "issuing_country",
        "issuing_jurisdiction",
        "portrait",
        "portrait_capture_date"
      ]
    case .MDL, .AGE, .GENERIC, .EMAIL:
      return []
    }
  }

  // TODO: This needs to be made in a more generic way
  public func valueForElementIdentifier(
    for documentType: DocumentTypeIdentifier,
    with documentId: String,
    elementIdentifier: String,
    parser: (String) -> String
  ) -> MdocValue {

    // Check if we have image data and early return them
    if let imageName = wallet.storage.walletDocuments
      .first(where: { $0.id == documentId })?.displayImages
      .first(where: { $0.name == elementIdentifier }) {
      return .image(imageName.image)
    }

    // Convert the Stored models to their [Key: Value] array
    let displayStrings = wallet.storage.walletDocuments
      .first(where: { $0.id == documentId })?.displayStrings
      .decodeGender()
      .parseDates(parser: parser)
      .mapTrueFalseToLocalizable()

    // Check if document type matches one of known models (pid or mdl)
    guard var displayStrings = displayStrings else {
      return .unavailable(LocalizableString.shared.get(with: .unavailableField))
    }

    if documentType == .MDL,
       let mdl = wallet.storage.mdlModel {

      // Flatten properties in order to be made in a Key: Value structure
      if let drivingPrivileges = mdl.getDrivingPrivileges(parser: parser) {
        displayStrings.append(drivingPrivileges)
      }

      displayStrings.append(
        contentsOf: decodeAgeOver(ageOverDictionary: mdl.ageOverXX)
      )
    } else if documentType == .PID, let pid = wallet.storage.pidModel {
      displayStrings.append(
        contentsOf: decodeAgeOver(ageOverDictionary: pid.ageOverXX)
      )
    }
    // Find the first Value that Matches given Key for document

    let value = displayStrings
      .first(where: { element in
        element.name == elementIdentifier
      })?.value
    // Return the value if found, or a static string that field was not found

    guard let isAvailable = value else {
      return .unavailable(LocalizableString.shared.get(with: .unavailableField))
    }

    return .string(isAvailable)
  }

  private func decodeAgeOver(ageOverDictionary: [Int: Bool]) -> [NameValue] {
    var nameValue: [NameValue] = []
    ageOverDictionary.sorted(by: {$0.key < $1.key}).forEach { key, value in
      nameValue.append(
        .init(
          name: "age_over_\(key)",
          value: value ? LocalizableString.shared.get(with: .yes) : LocalizableString.shared.get(with: .no)
        )
      )
    }
    return nameValue
  }
}
