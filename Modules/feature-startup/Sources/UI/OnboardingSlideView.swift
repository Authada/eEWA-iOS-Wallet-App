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
//  SwiftUIView.swift
//

import SwiftUI
import logic_ui
import logic_resources

struct OnboardingSlideView: View {
    let title: LocalizableString.Key
    let image: Image
    let description: LocalizableString.Key
    
    var body: some View {
        VStack(spacing: 20) {
            
            VSpacer.small()
            Text(title)
                .typography(Theme.shared.font.headlineSmall)
                .foregroundColor(ColorHelper.onboarding_title)
                .multilineTextAlignment(.center)
            
            ZStack(alignment: .center) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: getScreenRect().width / 2.5)
            }
            
            Text(description)
                .typography(Theme.shared.font.bodyLarge)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorHelper.textColor_grey)
            Spacer()
        }
        .frame(alignment: .top)
        .padding(.horizontal, 16)
    }
}
