//
//  BBActivityIndicatorView.swift
//
//  Copyright (c) 2020 Bibin Jacob Pulickal (https://github.com/bibinjacobpulickal)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI

public struct BBRefreshableScrollView<Content: View>: View {

    private let onRefresh: (@escaping () -> Void) -> Void
    private let content: Content
    private let offset: CGFloat

    @State private var state = BBRefreshState.waiting

    public init(offset: CGFloat = 50, onRefresh: @escaping (@escaping () -> Void) -> Void, @ViewBuilder content: () -> Content) {
        self.offset    = offset
        self.onRefresh = onRefresh
        self.content   = content()
    }

    public var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                BBPositionIndicatorView(type: .moving)
                    .frame(height: 0)
                content
                    .alignmentGuide(.top, computeValue: { _ in
                        (state == .loading) ? -offset : 0
                    })
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: offset)
                    BBActivityIndicatorView(isAnimating: state == .loading, hidesWhenStopped: state != .primed)
                }.offset(y: (state == .loading) ? 0 : -offset)
            }
        }
        .background(BBPositionIndicatorView(type: .fixed))
        .onPreferenceChange(BBPositionPreferenceKey.self) { values in
            if state != .loading {
                DispatchQueue.main.async {
                    let movingY = values.first { $0.type == .moving }?.y ?? 0
                    let fixedY = values.first { $0.type == .fixed }?.y ?? 0
                    let currentOffset = movingY - fixedY
                    if currentOffset > offset && state == .waiting {
                        state = .primed
                    } else if currentOffset < offset && state == .primed {
                        state = .loading
                        onRefresh {
                            withAnimation {
                                self.state = .waiting
                            }
                        }
                    }
                }
            }
        }
    }
}
