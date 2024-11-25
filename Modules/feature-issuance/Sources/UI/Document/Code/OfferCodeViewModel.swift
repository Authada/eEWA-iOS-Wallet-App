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
 * Modified by AUTHADA GmbH November 2024
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


public struct OfferCodeViewState: ViewState {
    let isLoading: Bool
    let error: ContentErrorView.Config?
    let config: IssuanceCodeUiConfig
    let title: LocalizableString.Key
    let caption: LocalizableString.Key
}

public final class OfferCodeViewModel<Router: RouterHost>: BaseViewModel<Router, OfferCodeViewState> {
    
    @Published var codeInput: String = ""
    @Published var codeIsFocused: Bool = true
    
    private let CODE_INPUT_DEBOUNCE = 250
    private let interactor: DocumentOfferInteractor
    
    var successNavigation: UIConfig.TwoWayNavigationType {
        return viewState.config.successNavigation
    }
    
    public init(
        router: Router,
        interactor: DocumentOfferInteractor,
        config: any UIConfigType
    ) {
        guard
            let config = config as? IssuanceCodeUiConfig
        else {
            fatalError("OfferCodeViewModel: Invalid configuraton")
        }
        self.interactor = interactor
        super.init(
            router: router,
            initialState: .init(
                isLoading: false,
                error: nil,
                config: config,
                title: .issuanceCodeTitle([config.issuerName]),
                caption: .issuanceCodeCaption([config.txCodeLength.string])
            )
        )
        
        subscribeToCodeInput()
    }
    
    
    func onPop() {
        switch viewState.config.navigationCancelType {
        case .popTo(let route):
            router.popTo(with: route)
        case .push(let route):
            router.push(with: route)
        case .pop:
            router.pop()
        }
    }
    
    private func onIssueDocuments() {
        Task {
            
            codeIsFocused = false
            
            
            let config = viewState.config
            
            let state = await Task.detached { () -> IssueOfferDocumentsPartialState in
                return await self.interactor.issueDocuments(with: config.offerUri, docOffers: config.docOffers, txCodeValue: self.codeInput)
            }.value
            
            switch state {
            case .success:
                router.push(
                    with: retrieveSuccessRoute(
                        with: .credentialOfferSuccessCaption([viewState.config.issuerName])
                    )
                )
            case .failure(let error):
                setNewState(isLoading: false, error: .init(
                    description: .custom(error.localizedDescription),
                    cancelAction: self.resetError()
                ))
                
            case .partialSuccess(let notIssued):
                router.push(
                    with: retrieveSuccessRoute(
                        with: .credentialOfferPartialSuccessCaption(
                            [
                                viewState.config.issuerName, notIssued.joined(separator: ", ")
                            ]
                        )
                    )
                )
            }
        }
    }
    
    private func resetError() {
        setNewState()
        self.codeInput = ""
        self.codeIsFocused = true
    }
    
    private func subscribeToCodeInput() {
        $codeInput
            .dropFirst()
            .debounce(for: .milliseconds(CODE_INPUT_DEBOUNCE), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self = self else { return }
                self.processCode(value: value)
            }.store(in: &cancellables)
    }
    
    private func processCode(value: String) {
        if value.count == viewState.config.txCodeLength {
            onIssueDocuments()
        }
    }
    
    private func setNewState(
        isLoading: Bool = false,
        error: ContentErrorView.Config? = nil,
        config: IssuanceCodeUiConfig? = nil,
        title: LocalizableString.Key? = nil,
        caption: LocalizableString.Key? = nil
    ) {
        setState { previousSate in
                .init(
                    isLoading: isLoading,
                    error: error,
                    config: config ?? previousSate.config,
                    title: title ?? previousSate.title,
                    caption: caption ?? previousSate.caption
                )
        }
    }
    
    private func retrieveSuccessRoute(with key: LocalizableString.Key) -> AppRoute {
        
        var navigationType: UIConfig.DeepLinkNavigationType {
            return switch self.viewState.config.successNavigation {
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
}
