//
//  ContentView.swift
//  iOSExample
//
//  Created by Bibin Jacob Pulickal on 04/03/21.
//

import SwiftUI
import BBRefreshableScrollView

struct ContentView: View {

    @State private var rows = [1, 2, 3, 4]

    var body: some View {
        NavigationView {
            BBRefreshableScrollView { completion in
                addNewRow {
                    completion()
                }
            } content: {
                VStack {
                    Divider()
                    ForEach(rows, id: \.self) { row in
                        HStack {
                            Text("Row \(row)")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("BBRefreshableScrollView")
        }
    }

    func addNewRow(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            rows.append(rows.count + 1)
            completion()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
