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
import logic_ui
import logic_resources
import feature_common

struct DocumentSuccessState: ViewState {
  let error: ContentErrorView.Config?
  let title: LocalizableString.Key
  let caption: LocalizableString.Key?
  let mainDisplayValue: String?
  let config: IssuanceFlowUiConfig
  let documentIdentifier: String
  let documentSymbol: Image?
  let documentTypeName: String?
}

final class DocumentSuccessViewModel<Router: RouterHost>: BaseViewModel<Router, DocumentSuccessState> {

  private let interactor: DocumentSuccessInteractor

  public init(
    router: Router,
    interactor: DocumentSuccessInteractor,
    config: any UIConfigType,
    documentIdentifier: String
  ) {

    guard let config = config as? IssuanceFlowUiConfig else {
      fatalError("ExternalLoginViewModel:: Invalid configuraton")
    }

    self.interactor = interactor

    super.init(
      router: router,
      initialState: .init(
        error: nil,
        title: .issuanceSuccessTitle,
        caption: nil,
        mainDisplayValue: nil,
        config: config,
        documentIdentifier: documentIdentifier,
        documentSymbol: nil,
        documentTypeName: nil
      )
    )
  }

  func initialize() async {
    setNewState(
      caption: interactor.getDocumentSuccessCaption(for: viewState.documentIdentifier),
      mainDisplayValue: interactor.getMainDisplayValue(for: viewState.documentIdentifier),
      documentSymbol: interactor.getDocumentSymbol(for: viewState.documentIdentifier),
      documentTypeName: interactor.getDocumentTypeName(for: viewState.documentIdentifier)
    )
  }

  func onIssue() {

    var flow: IssuanceDetailUiConfig.Flow {
      switch viewState.config.flow {
      case .noDocument:
        return .noDocument(viewState.documentIdentifier)
      case .extraDocument:
        return .extraDocument(viewState.documentIdentifier)
      }
    }

    router.push(
      with: .issuanceDocumentDetails(
        config: IssuanceDetailUiConfig(
          flow: flow
        )
      )
    )
  }

  private func setNewState(
    error: ContentErrorView.Config? = nil,
    caption: LocalizableString.Key? = nil,
    mainDisplayValue: String? = nil,
    documentSymbol: Image? = nil,
    documentTypeName: String? = nil
  ) {
    setState { previous in
        .init(
          error: error,
          title: previous.title,
          caption: caption ?? previous.caption,
          mainDisplayValue: mainDisplayValue ?? previous.mainDisplayValue,
          config: previous.config,
          documentIdentifier: previous.documentIdentifier,
          documentSymbol: documentSymbol ?? previous.documentSymbol,
          documentTypeName: documentTypeName ?? previous.documentTypeName
        )
    }
  }
}
