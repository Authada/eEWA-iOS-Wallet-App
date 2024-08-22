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
//  OnboardingView.swift
//

import SwiftUI
import logic_ui
import logic_resources
import feature_common
import logic_business

public struct OnboardingView<Router: RouterHost>: View {
    @State private var tabSelection = 1
    
    public let router: Router
    
    public init(
        with router: Router
    ) {
        self.router = router
    }
    
    public var body: some View {
        ContentScreenView(
            padding: .zero,
            background: ColorHelper.onboarding_background
        ) {
            VSpacer.custom(size: 64)
            TabView(selection: $tabSelection) {
                OnboardingSlideView(title: .onboardingtitleOne,
                                    image: Theme.shared.image.identID,
                                    description: .onboardingInfoOne).tag(1)
                OnboardingSlideView(title: .onboardingtitleTwo,
                                    image: Theme.shared.image.lock,
                                    description: .onboardingInfoTwo).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .background(ColorHelper.surface)
            .cornerRadius(10)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .animation(.default, value: tabSelection)
            
            VSpacer.large()
            
            WrapButtonView(
                style: .primary,
                title: .onboardingNextBtn,
                onAction: {
                    if tabSelection == 1 {
                        tabSelection = 2
                    } else {
                        self.router.push(with: .quickPin(config: QuickPinUiConfig(flow: .set)))
                    }
                    
                }()
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

