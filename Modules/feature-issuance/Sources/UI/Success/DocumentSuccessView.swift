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
import logic_ui
import logic_resources

public struct DocumentSuccessView<Router: RouterHost>: View {
    
    @ObservedObject var viewModel: DocumentSuccessViewModel<Router>
    
    let checkmark = Theme.shared.image.checkmarkCircleFill
    
    public init(
        with router: Router,
        and interactor: DocumentSuccessInteractor,
        config: any UIConfigType,
        documentIdentifier: String
    ) {
        self.viewModel = .init(
            router: router,
            interactor: interactor,
            config: config,
            documentIdentifier: documentIdentifier
        )
    }
    
    public var body: some View {
        ContentScreenView(errorConfig: viewModel.viewState.error) {
            
            ContentTitleView(
                title: viewModel.viewState.title,
                caption: viewModel.viewState.caption,
                titleColor: ColorHelper.highlight,
                topSpacing: .withoutToolbar
            )
            
            VSpacer.large()
            
            document
            
            Spacer()
            
            checkmark.resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 256, maxHeight: 256)
            
            Spacer()
            
            footer
        }
        .task {
            await viewModel.initialize()
        }
    }
    
    private var document: some View {
        VStack(spacing: SPACING_MEDIUM) {
            
            HStack {
                
                if let documentImage = viewModel.viewState.documentSymbol {
                    documentImage.resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(ColorHelper.textColor)
                        .frame(maxWidth: 58, maxHeight: 58)
                        
                }
                
                if let documentTypeName = viewModel.viewState.documentTypeName {
                    Text(documentTypeName)
                        .typography(Theme.shared.font.headlineSmall)
                        .foregroundColor(ColorHelper.textColor)
                }
                
                Spacer()
            }
            
            HStack {
                if let infoString = viewModel.viewState.mainDisplayValue {
                    Text(infoString)
                        .typography(Theme.shared.font.titleMedium)
                        .foregroundColor(ColorHelper.textColor)
                }
                
                Spacer()
            }
        }
        .padding(SPACING_MEDIUM_LARGE)
        .frame(maxWidth: .infinity)
        .background(ColorHelper.background)
        .roundedCorner(Theme.shared.shape.small, corners: .allCorners)
    }
    
    @ViewBuilder
    private var footer: some View {
        WrapButtonView(
            style: .primary,
            title: .issuanceSuccessNextButton,
            onAction: viewModel.onIssue()
        )
    }
}
