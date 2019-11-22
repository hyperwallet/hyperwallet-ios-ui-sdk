//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import HyperwalletSDK
import UIKit

/// Factories of widget
final class WidgetFactory {
    /// Defines a dictionary of the widget
    static let widgetDefinition: Dictionary = [
        HyperwalletDataType.text.rawValue: TextWidget.self,
        HyperwalletDataType.number.rawValue: NumberWidget.self,
        HyperwalletDataType.selection.rawValue: SelectionWidget.self,
        HyperwalletDataType.expiryDate.rawValue: ExpiryDateWidget.self,
        HyperwalletDataType.phone.rawValue: PhoneWidget.self,
        HyperwalletDataType.date.rawValue: DateWidget.self
    ]

    /// Creates a new instance of a `Widget` based on the `HyperwalletField.type`
    static func newWidget(field: HyperwalletField, pageName: String, pageGroup: String) -> AbstractWidget {
        guard let widget = widgetDefinition[field.dataType ?? HyperwalletDataType.text.rawValue] else {
            return TextWidget(field: field, pageName: pageName, pageGroup: pageGroup)
        }
        return widget.init(field: field, pageName: pageName, pageGroup: pageGroup)
    }
}
