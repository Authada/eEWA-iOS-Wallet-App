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
import logic_ui
import logic_resources
import logic_business
import feature_common
import logic_core


struct DocumentOfferViewState: ViewState {
    let isLoading: Bool
    let documentOfferUiModel: DocumentOfferUIModel
    let error: ContentErrorView.Config?
    let config: IssuaceOfferUIConfig
    let offerUri: String
    let allowIssue: Bool
    let isValidated: Bool
    let needsAuth: Bool
    
    var title: LocalizableString.Key {
        return .requestCredentialOfferTitle([documentOfferUiModel.issuerName])
    }
    
    var successNavigation: UIConfig.TwoWayNavigationType {
        return config.navigationSuccessType
    }
    
    var cancelNavigation: UIConfig.ThreeWayNavigationType {
        return config.navigationCancelType
    }
}

@MainActor
final class DocumentOfferViewModel<Router: RouterHost>: BaseViewModel<Router, DocumentOfferViewState> {
    
    private let interactor: DocumentOfferInteractor
    
    @Published var isCancelModalShowing: Bool = false
    
    init(
        router: Router,
        interactor: DocumentOfferInteractor,
        config: any UIConfigType
    ) {
        var configToUse: IssuaceOfferUIConfig
        if let config = config as? IssuaceOfferUIConfig {
            configToUse = config
        } else {
            guard
                let config = config as? UIConfig.Generic,
                let offerUri = config.arguments["uri"],
                let needsAuth = config.arguments["needsAuth"]
            else
            {
                fatalError("DocumentOfferViewModel:: Invalid configuraton")
            }
            configToUse = IssuaceOfferUIConfig(offerUri: offerUri,
                                               needsAuth: needsAuth == "true",
                                               navigationSuccessType: config.navigationSuccessType,
                                               navigationCancelType: config.navigationCancelType)
        }
        
        self.interactor = interactor
        super.init(
            router: router,
            initialState: .init(
                isLoading: true,
                documentOfferUiModel: DocumentOfferUIModel.mock(),
                error: nil,
                config: configToUse,
                offerUri: configToUse.offerUri,
                allowIssue: false,
                isValidated: false,
                needsAuth: configToUse.needsAuth
            )
        )
    }
    
    func processRequest() async {
        switch await self.interactor.processOfferRequest(with: viewState.offerUri) {
        case .success(let uiModel):
            setNewState(
                documentOfferUiModel: uiModel,
                allowIssue: !uiModel.uiOffers.isEmpty,
                isValidated: uiModel.isValidated,
                needsAuth: viewState.config.needsAuth
            )
            if !self.viewState.needsAuth {
                onIssueDocuments()
            }
        case .failure(let error):
            setNewState(
                error: ContentErrorView.Config(
                    description: .custom(error.localizedDescription),
                    cancelAction: self.onPop()
                ),
                allowIssue: false
            )
        }
    }
    
    
    func onIssueDocuments() {
        if viewState.needsAuth {
            let config = IssuaceOfferUIConfig(offerUri: self.viewState.offerUri, needsAuth: false, navigationSuccessType: self.viewState.successNavigation, navigationCancelType: self.viewState.cancelNavigation)
            setNewState(config: config)
            router.push(with: .biometry(
                config: UIConfig.Biometry(
                    title: viewState.title,
                    caption: .requestDataShareBiometryCaption,
                    quickPinOnlyCaption: .requestDataShareQuickPinCaption,
                    navigationSuccessType: .popTo( .credentialOfferRequest(config: config)
                    ),
                    navigationBackType: .popTo(.dashboard),
                    isPreAuthorization: false,
                    shouldInitializeBiometricOnCreate: true
                )))
        } else {
            issueDocuments()
        }
    }
    
    func issueDocuments() {
        if let code = viewState.documentOfferUiModel.txCode
        {
            let config = IssuanceCodeUiConfig(
                offerUri: viewState.offerUri,
                issuerName: viewState.documentOfferUiModel.issuerName,
                txCodeLength: code.codeLenght,
                docOffers: viewState.documentOfferUiModel.docOffers,
                successNavigation: viewState.successNavigation,
                navigationCancelType: .popTo(.dashboard))
            router.push(with: .issuanceCode(config: config))
            return
        }
        
        Task {
            setNewState(isLoading: true)
            switch await self.interactor.issueDocuments(
                with: viewState.offerUri,
                docOffers: viewState.documentOfferUiModel.docOffers,
                txCodeValue: nil
            ) {
            case .success:
                router.push(
                    with: retrieveSuccessRoute(
                        with: .credentialOfferSuccessCaption([viewState.documentOfferUiModel.issuerName])
                    )
                )
            case .failure(let error):
                setNewState(
                    error: ContentErrorView.Config(
                        description: .custom(error.localizedDescription),
                        cancelAction: self.setNewState(error: nil)
                    )
                )
            case .partialSuccess(let notIssued):
                router.push(
                    with: retrieveSuccessRoute(
                        with: .credentialOfferPartialSuccessCaption(
                            [
                                viewState.documentOfferUiModel.issuerName, notIssued.joined(separator: ", ")
                            ]
                        )
                    )
                )
            }
        }
    }
    
    
    func onShowCancelModal() {
        isCancelModalShowing = !isCancelModalShowing
    }
    
    func onPop() {
        isCancelModalShowing = false
        switch viewState.cancelNavigation {
        case .popTo(let route):
            router.popTo(with: route)
        case .push(let route):
            router.push(with: route)
        case .pop:
            router.pop()
        }
    }
    
    func handleNotification(with info: [AnyHashable: Any]) {
        guard let uri = info["uri"] as? String else {
            return
        }
        setNewState(
            isLoading: true,
            documentOfferUiModel: DocumentOfferUIModel.mock(),
            allowIssue: false,
            config: .init(
                offerUri: uri,
                needsAuth: viewState.config.needsAuth,
                navigationSuccessType: viewState.config.navigationSuccessType,
                navigationCancelType: viewState.config.navigationCancelType
            ),
            offerUri: uri,
            needsAuth: viewState.config.needsAuth
        )
        Task {
            await self.processRequest()
        }
    }
    
    private func retrieveSuccessRoute(with key: LocalizableString.Key) -> AppRoute {
        
        var navigationType: UIConfig.DeepLinkNavigationType {
            return switch self.viewState.successNavigation {
            case .popTo(let route): .pop(screen: route)
            case .push(let route): .push(screen: route)
            }
        }
        
        return .success(
            config: UIConfig.Success(
                title: .success,
                subtitle: key,
                buttons: [
                    .init(
                        title: .credentialOfferSuccessButton,
                        style: .primary,
                        navigationType: navigationType
                    )
                ],
                visualKind: .defaultIcon
            )
        )
    }
    
    private func setNewState(
        isLoading: Bool = false,
        error: ContentErrorView.Config? = nil,
        documentOfferUiModel: DocumentOfferUIModel? = nil,
        allowIssue: Bool? = nil,
        config: IssuaceOfferUIConfig? = nil,
        offerUri: String? = nil,
        needsTxCode: Bool? = false,
        isValidated: Bool? = false,
        needsAuth: Bool? = true
    ) {
        setState { previousState in
                .init(
                    isLoading: isLoading,
                    documentOfferUiModel: documentOfferUiModel ?? previousState.documentOfferUiModel,
                    error: error,
                    config: config ?? previousState.config,
                    offerUri: offerUri ?? previousState.offerUri,
                    allowIssue: allowIssue ?? previousState.allowIssue,
                    isValidated: isValidated ?? previousState.isValidated,
                    needsAuth: needsAuth ?? previousState.needsAuth
                )
        }
    }
}
