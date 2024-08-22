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

struct BearerHeaderView: View {

  let item: BearerUIModel
  let isLoading: Bool
  let onMoreClicked: () -> Void

  @ViewBuilder
  var userImage: some View {
    item.value.image
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(maxWidth: 64.0)
      .cornerRadius(8.0)
  }

  init(
    item: BearerUIModel,
    isLoading: Bool,
    onMoreClicked: @escaping @autoclosure () -> Void
  ) {
    self.item = item
    self.isLoading = isLoading
    self.onMoreClicked = onMoreClicked
  }

  var body: some View {
    VStack(alignment: .leading) {
      BearerCellView(
        item: item,
        isLoading: isLoading,
        onMoreClicked: onMoreClicked()
      )
    }
    .padding(.vertical, SPACING_EXTRA_LARGE)
    .background(ColorHelper.background)
    .roundedCorner(SPACING_MEDIUM, corners: [.bottomLeft, .bottomRight])
  }
}
