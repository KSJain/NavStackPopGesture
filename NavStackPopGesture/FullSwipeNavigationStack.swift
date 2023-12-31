//
//  FullSwipeNavigationStack.swift
//  NavStackPopGesture
//
//  Created by Kartikeya Saxena Jain on 10/8/23.
//

import SwiftUI

struct FullSwipeNavigationStack<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var customGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.name = UUID().uuidString
        gesture.isEnabled = true
        return gesture
    }()
    
    var body: some View {
        NavigationStack {
            content
                .background {
                    AttachGestureView(gesture: $customGesture)
                }
                .background {
                    AttachGestureView(gesture: $customGesture)
                }
        }
        .environment(\.popGestureID, customGesture.name)
        .onReceive(NotificationCenter.default.publisher(for: .init(customGesture.name ?? "")), perform: { info in
            if let userInfo = info.userInfo, let status = userInfo["status"] as? Bool {
                customGesture.isEnabled = status
            }
        })
    }
}

#Preview {
    ContentView()
}

fileprivate struct PopNotificationID: EnvironmentKey {
    static var defaultValue: String?
}

fileprivate extension EnvironmentValues {
    var popGestureID: String? {
        get {
            self[PopNotificationID.self]
        }
        set {
            self[PopNotificationID.self] = newValue
        }
    }
}

extension View {
    @ViewBuilder
    func enableFullSwipePop(_ isEnabled: Bool) -> some View {
        self
            .modifier(FullSwipeModifier(isEnabled: isEnabled))
    }
}

fileprivate struct FullSwipeModifier: ViewModifier {
    var isEnabled: Bool
    @Environment(\.popGestureID) private var gestureID
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isEnabled, initial: true) { oldValue, newValue in
                guard let gestureID else { return }
                NotificationCenter.default.post(
                    name: .init(gestureID),
                    object: nil,
                    userInfo: ["status": newValue]
                )
            }
            .onDisappear(perform: {
                guard let gestureID else { return }
                NotificationCenter.default.post(
                    name: .init(gestureID),
                    object: nil,
                    userInfo: ["status": false]
                )

            })
    }
}

fileprivate struct AttachGestureView: UIViewRepresentable {
    @Binding var gesture: UIPanGestureRecognizer
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            if let parentViewController = uiView.parentViewController {
                if let navController = parentViewController.navigationController {
                    if let _ = navController.view.gestureRecognizers?.first(where: { $0.name == gesture.name }) {
                        print("Already Attached")
                    } else {
                        navController.addFullswipeGesture(gesture)
                        print("Attached")
                    }
                }
            }
        }
    }
}

fileprivate extension UINavigationController {
    func addFullswipeGesture(_ gesture:UIGestureRecognizer) {
        guard let gestureSelector = interactivePopGestureRecognizer?.value(forKey: "targets") else { return }
        
        gesture.setValue(gestureSelector, forKey: "targets")
        view.addGestureRecognizer(gesture)
    }
}

fileprivate extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) {
            $0.next
        }.first(where: { $0 is UIViewController}) as? UIViewController
    }
}
