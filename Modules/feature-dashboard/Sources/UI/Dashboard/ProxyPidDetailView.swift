/*
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

//
//  ProxyPidDetailView.swift
//

import SwiftUI
import logic_ui
import logic_resources

public struct ProxyPidDetailView<Router: RouterHost>: View {
    
    public let router: Router
    
    public init(
        with router: Router
    ) {
        self.router = router
    }
    
    public var body: some View {
        ContentScreenView(
            padding: .zero
        ) {
            VStack {
                Spacer()
                
                Text(.proxyDetailTitle)
                    .typography(Theme.shared.font.headlineSmall)
                    .foregroundColor(ColorHelper.textColor)
                    .multilineTextAlignment(.center)
                
                ZStack(alignment: .center) {
                    Theme.shared.image.confirmId
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Theme.shared.color.success)
                        .frame(height: getScreenRect().width / 2.5)
                }
                
                VStack(alignment: .leading) {
                    Text(.proxyDetailCapition)
                        .typography(Theme.shared.font.bodyLarge)
                        .foregroundColor(ColorHelper.textColor_grey)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.01)
                        .padding(.bottom, 1)
                    
                    Text(.proxyDetailSubtitle)
                        .typography(Theme.shared.font.titleMedium)
                        .foregroundColor(ColorHelper.textColor_grey)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.01)
                        .padding(.bottom, 1)
                    
                    HStack(alignment: .top) {
                        Text("1.")
                            .typography(Theme.shared.font.bodyLarge)
                            .foregroundColor(ColorHelper.textColor_grey)
                            .multilineTextAlignment(.leading)
                        Text(.proxyDetailInfoOne)
                            .typography(Theme.shared.font.bodyLarge)
                            .foregroundColor(ColorHelper.textColor_grey)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.01)
                    }
                    HStack(alignment: .top) {
                        Text("2.")
                            .typography(Theme.shared.font.bodyLarge)
                            .foregroundColor(ColorHelper.textColor_grey)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.01)
                        Text(.proxyDetailInfoTwo)
                            .typography(Theme.shared.font.bodyLarge)
                            .foregroundColor(ColorHelper.textColor_grey)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.01)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
                
                Spacer()
                
                WrapButtonView(
                    style: .primary,
                    title: .closeButton,
                    onAction: {
                        self.router.pop()
                    }()
                )
                
                VSpacer.large()
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
    }
}
