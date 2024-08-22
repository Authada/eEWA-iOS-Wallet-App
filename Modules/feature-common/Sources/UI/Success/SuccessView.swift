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

public struct SuccessView<Router: RouterHost>: View {
    
    @ObservedObject var viewmodel: SuccessViewModel<Router>
    
    public init(
        with router: Router,
        and config: any UIConfigType,
        also deepLinkController: DeepLinkController
    ) {
        self.viewmodel = .init(config: config, router: router, deepLinkController: deepLinkController)
    }
    
    public var body: some View {
        ContentScreenView {
            mainView()
        }
    }
    
    private func getCenteredIcon() -> Image {
        return switch viewmodel.viewState.config.visualKind {
        case .defaultIcon:
            Theme.shared.image.checkmarkCircleFill
        case .customIcon(let image):
            image
        }
    }
    
    private func mainView() -> some View {
        VStack {
            
            Spacer()
            
            Text(viewmodel.viewState.config.title)
              .typography(Theme.shared.font.headlineSmall)
              .foregroundColor(ColorHelper.textColor)
              .multilineTextAlignment(.center)
            
            ZStack(alignment: .center) {
                getCenteredIcon()
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Theme.shared.color.success)
                    .frame(height: getScreenRect().width / 2.5)
            }
            
            Text(viewmodel.viewState.config.subtitle)
              .typography(Theme.shared.font.bodyMedium)
              .foregroundColor(ColorHelper.textColor)
              .multilineTextAlignment(.center)
            Spacer()
            
            VStack {
                ForEach(viewmodel.viewState.config.buttons, id: \.id) { button in
                    WrapButtonView(
                        style: button.style == .primary ? .primary : .secondary,
                        title: button.title,
                        onAction: viewmodel.onButtonClicked(with: button)
                    )
                }
            }
        }
    }
}
