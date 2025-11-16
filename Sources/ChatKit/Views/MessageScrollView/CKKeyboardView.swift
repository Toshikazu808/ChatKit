//
//  CKKeyboardView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/12/25.
//

import SwiftUI

public struct CKKeyboardView: View {
    public static let height: CGFloat = 50
    public static let withHeaderHeight: CGFloat = 28
    public static let padding: CGFloat = 8
    public static let borderWidth: CGFloat = 0.3
    
    public let placeholder: String
    @Binding public var text: String
    public let initialText: String
    public let type: UIKeyboardType
    public let submitLabel: SubmitLabel
    public let cornerRadius: CGFloat
    public let header: String?
    public let showShadow: Bool
    public let minHeight: CGFloat
    public let capitalization: TextInputAutocapitalization
    public let onSubmit: (() -> Void)?
    
    public init(placeholder: String, text: Binding<String>, type: UIKeyboardType, initialText: String = "", header: String? = nil, submitLabel: SubmitLabel = .done, cornerRadius: CGFloat = 8, showShadow: Bool = true, minHeight: CGFloat = CKKeyboardView.height, onSubmit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.initialText = initialText
        self.type = type
        self.header = header
        self.submitLabel = submitLabel
        self.cornerRadius = cornerRadius
        self.minHeight = minHeight
        self.showShadow = showShadow
        self.onSubmit = onSubmit
        self.capitalization = switch type {
        case .emailAddress, .URL: .never
        case .default: .sentences
        default: .words
        }
    }
    
    public var body: some View {
        VStack(spacing: 1) {
            if let header {
                HStack {
                    Text(header)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .font(.caption)
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
            
            TextField(placeholder, text: $text, axis: .vertical)
                .submitLabel(submitLabel)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(capitalization)
                .keyboardType(type)
                .frame(minHeight: minHeight)
                .padding(Self.padding)
                .onChange(of: text) { _, newValue in
                    guard let s = newValue.last, s == "\n" else { return }
                    text.removeLast()
                    onSubmit?()
                }
        }
        .background {
            RoundedRectangle(cornerRadius: cornerRadius).fill(Theme.babyBlue)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        CKKeyboardView(placeholder: "test@email.com", text: .constant(""), type: .emailAddress)
        
        CKKeyboardView(placeholder: "test@email.com", text: .constant(""), type: .emailAddress, header: "email", minHeight: CKKeyboardView.withHeaderHeight)
    }
    .padding()
}
