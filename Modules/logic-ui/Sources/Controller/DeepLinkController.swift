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
import logic_business
import logic_core

public struct DeepLink {}

public protocol DeepLinkController {
  func hasDeepLink(url: URL) -> DeepLink.Executable?
  func handleDeepLinkAction(routerHost: RouterHost, deepLinkExecutable: DeepLink.Executable) async
  func getPendingDeepLinkAction() -> DeepLink.Executable?
  func cacheDeepLinkURL(url: URL)
  func removeCachedDeepLinkURL()
}

final class DeepLinkControllerImpl: DeepLinkController {

  private let prefsController: PrefsController
  private let walletKitController: WalletKitController
  private let urlSchemaController: UrlSchemaController

  init(
    prefsController: PrefsController,
    walletKitController: WalletKitController,
    urlSchemaController: UrlSchemaController
  ) {
    self.prefsController = prefsController
    self.walletKitController = walletKitController
    self.urlSchemaController = urlSchemaController
  }

  public func getPendingDeepLinkAction() -> DeepLink.Executable? {
    if let cachedLink = prefsController.getString(forKey: .cachedDeepLink),
       let url = URL(string: cachedLink) {
      return hasDeepLink(url: url)
    }
    return nil
  }

  public func hasDeepLink(url: URL) -> DeepLink.Executable? {
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
       let scheme = components.scheme,
       let action = DeepLink.Action.parseType(with: scheme, and: urlSchemaController) {
      return DeepLink.Executable(link: components, plainUrl: url, action: action)
    }
    return nil
  }

  public func handleDeepLinkAction(
    routerHost: RouterHost,
    deepLinkExecutable: DeepLink.Executable
  ) async  {

    var isVciExecutable: Bool {
        deepLinkExecutable.action == .credential_offer || deepLinkExecutable.action == .openid4ci
    }

    guard
      routerHost.userIsLoggedInWithDocuments() || isVciExecutable
    else {
      if let url = deepLinkExecutable.link.url {
        cacheDeepLinkURL(url: url)
      }
      return
    }

    removeCachedDeepLinkURL()

    switch deepLinkExecutable.action {
    case .openid4vp:
        let session = await walletKitController.startSameDevicePresentation(deepLink: deepLinkExecutable.link)
        DispatchQueue.main.async {
            if !routerHost.isScreenForeground(with: .presentationRequest(presentationCoordinator: session)) {
                routerHost.push(with: .presentationRequest(presentationCoordinator: session))
            } else {
                self.postNotification(
                    with: NSNotification.PresentationVC,
                    and: ["session": session]
                )
            }
        }
    case .external:
      deepLinkExecutable.plainUrl.open()
    case .credential_offer:
      let config = UIConfig.Generic(
        arguments: ["uri": deepLinkExecutable.plainUrl.absoluteString],
        navigationSuccessType: routerHost.userIsLoggedInWithDocuments()
        ? .popTo(.dashboard)
        : .push(.dashboard),
        navigationCancelType: .pop
      )
      if !routerHost.isScreenForeground(with: .credentialOfferRequest(config: config)) {
        routerHost.push(with: .credentialOfferRequest(config: config))
      } else {
        postNotification(
          with: NSNotification.CredentialOffer,
          and: ["uri": deepLinkExecutable.plainUrl.absoluteString]
        )
      }
    case .openid4ci:
        postNotification(
          with: NSNotification.AuthenticationCode,
          and: ["authenticationToken": deepLinkExecutable.plainUrl.absoluteString])
    }
  }

  public func cacheDeepLinkURL(url: URL) {
    prefsController.setValue(url.absoluteString, forKey: .cachedDeepLink)
  }

  public func removeCachedDeepLinkURL() {
    prefsController.remove(forKey: .cachedDeepLink)
  }

  private func postNotification(
    with name: NSNotification.Name,
    and info: [AnyHashable: Any]? = nil
  ) {
    NotificationCenter.default.post(
      name: name,
      object: nil,
      userInfo: info
    )
  }
}

public extension DeepLink {
  struct Executable: Equatable {
    public let link: URLComponents
    public let plainUrl: URL
    public let action: DeepLink.Action
  }
}

public extension DeepLink {
  enum Action: String, Equatable {

    case openid4vp
    case credential_offer
    case external
    case openid4ci

    private var name: String {
      return rawValue.replacingOccurrences(of: "_", with: "-")
    }

    private func getSchemas(
      with urlSchemaController: UrlSchemaController
    ) -> [String] {
      return urlSchemaController.retrieveSchemas(with: name)
    }

    static func parseType(
      with scheme: String,
      and urlSchemaController: UrlSchemaController
    ) -> Action? {
      switch scheme {
      case _ where openid4vp.getSchemas(with: urlSchemaController).contains(scheme):
        return .openid4vp
      case _ where credential_offer.getSchemas(with: urlSchemaController).contains(scheme):
        return .credential_offer
      case _ where openid4ci.getSchemas(with: urlSchemaController).contains(scheme):
        return .openid4ci
      default:
        return .external
      }
    }
  }
}

public extension NSNotification {
  static let PresentationVC = Notification.Name.init("PresentationVC")
  static let CredentialOffer = Notification.Name.init("CredentialOffer")
  static let AuthenticationCode = Notification.Name.init("AuthenticationCode")
}
