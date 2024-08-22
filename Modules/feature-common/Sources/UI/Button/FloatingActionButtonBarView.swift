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
import logic_resources

public struct FloatingActionButtonBarView: View {

  @Environment(\.colorScheme) var colorScheme

  public let isLoading: Bool
  public let backgroundColor: Color
  public let edgeInsets: EdgeInsets
  public let addAction: () -> Void
  public let shareAction: () -> Void

  public init(
    isLoading: Bool = false,
    backgroundColor: Color = .clear,
    edgeInsets: EdgeInsets = .init(),
    addAction: @escaping @autoclosure () -> Void,
    shareAction: @escaping @autoclosure () -> Void
  ) {
    self.isLoading = isLoading
    self.backgroundColor = backgroundColor
    self.edgeInsets = edgeInsets
    self.addAction = addAction
    self.shareAction = shareAction
  }

    public var body: some View {
        HStack(spacing: SPACING_MEDIUM) {
            
#if DEBUG
            FloatingActionButtonView(
                title: .addDoc,
                textColor: ColorHelper.textColor_inverted,
                backgroundColor: ColorHelper.primary,
                icon: Theme.shared.image.plus,
                iconColor: ColorHelper.textColor_inverted,
                isLoading: isLoading,
                action: addAction
            )
#endif
            
            FloatingActionButtonView(
                title: .scanQrCode,
                textColor: ColorHelper.textColor,
                backgroundColor: ColorHelper.surface,
                icon: Theme.shared.image.qrScan,
                iconColor: ColorHelper.surface,
                isLoading: isLoading,
                bordered: true,
                action: shareAction
            )
            
        }
        .padding(edgeInsets)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
}
