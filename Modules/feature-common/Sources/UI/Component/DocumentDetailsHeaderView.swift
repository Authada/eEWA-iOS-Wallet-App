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
import logic_ui

public struct DocumentDetailsHeaderView: View {

  let documentName: String
  let holdersName: String
  let userIcon: Image
  let hasDocumentExpired: Bool
  let isLoading: Bool
  let actions: [ContentHeaderView.Action]?
  let onBack: (() -> Void)?

  public init(
    documentName: String,
    holdersName: String,
    userIcon: Image,
    hasDocumentExpired: Bool,
    isLoading: Bool,
    actions: [ContentHeaderView.Action]?,
    onBack: (() -> Void)?
  ) {
    self.holdersName = holdersName
    self.userIcon = userIcon
    self.documentName = documentName
    self.hasDocumentExpired = hasDocumentExpired
    self.isLoading = isLoading
    self.actions = actions
    self.onBack = onBack
  }

  public var body: some View {
    VStack {
      DocumentDetailsHeaderCellView(
        documentName: documentName,
        holdersName: holdersName,
        userIcon: userIcon,
        hasDocumentExpired: hasDocumentExpired,
        isLoading: isLoading,
        actions: actions,
        onBack: onBack
      )
    }
  }
}

extension DocumentDetailsHeaderView {

  struct DocumentDetailsHeaderCellView: View {

    let documentName: String
    let holdersName: String
    let userIcon: Image
    let hasDocumentExpired: Bool
    let isLoading: Bool
    let actions: [ContentHeaderView.Action]?
    let onBack: (() -> Void)?

    public init(
      documentName: String,
      holdersName: String,
      userIcon: Image,
      hasDocumentExpired: Bool,
      isLoading: Bool,
      actions: [ContentHeaderView.Action]?,
      onBack: (() -> Void)?
    ) {
      self.documentName = documentName
      self.holdersName = holdersName
      self.userIcon = userIcon
      self.hasDocumentExpired = hasDocumentExpired
      self.isLoading = isLoading
      self.actions = actions
      self.onBack = onBack
    }

    public var body: some View {
      VStack(alignment: .leading, spacing: SPACING_SMALL) {

        if let onBack {
          ContentHeaderView(
            dismissIcon: Theme.shared.image.xmark,
            foregroundColor: Theme.shared.color.primary,
            actions: actions
          ) {
            onBack()
          }
        }

        Text(documentName)
          .typography(Theme.shared.font.headlineSmall)
          .foregroundColor(ColorHelper.textColor)
          .shimmer(isLoading: isLoading)

        Text(holdersName)
          .typography(Theme.shared.font.bodyLarge)
          .foregroundColor(ColorHelper.textColor)
          .padding(.bottom)
          .shimmer(isLoading: isLoading)

        HStack {
          userIcon
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100)
            .roundedCorner(Theme.shared.shape.extraSmall, corners: .allCorners)
          Spacer()
        }
        .shimmer(isLoading: isLoading)
      }
      .padding(SPACING_MEDIUM)
      .frame(maxWidth: .infinity)
      .background(ColorHelper.background)
      .roundedCorner(Theme.shared.shape.small, corners: [.bottomLeft, .bottomRight])
    }
  }
}
