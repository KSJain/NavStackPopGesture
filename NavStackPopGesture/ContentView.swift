//
//  ContentView.swift
//  NavStackPopGesture
//
//  Created by Kartikeya Saxena Jain on 10/8/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isEnabled: Bool = false
    
    var body: some View {
        FullSwipeNavigationStack {
            List {
                Section("Sample Header") {
                    NavigationLink("Full Swipe View") {
                        List {
                            Toggle("Enable Full Swipe Pop", isOn: $isEnabled)
                                .enableFullSwipePop(isEnabled)
                        }
                        .navigationTitle("Full Swipe View")
                    }
                    
                    NavigationLink("Leading Swipe View") {
                        Text("")
                            .navigationTitle("Leading Swipe View")
                    }
                }
            }
            .navigationTitle("Full Swipe Pop")
        }
    }
}

#Preview {
    ContentView()
}
