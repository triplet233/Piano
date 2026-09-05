import SwiftUI

extension View {
    @ViewBuilder
    func inlineNavigationTitle() -> some View {
#if os(iOS)
        navigationBarTitleDisplayMode(.inline)
#else
        self
#endif
    }
    
    @ViewBuilder
    func presentationDetentsMedium() -> some View {
#if os(iOS)
        presentationDetents([.medium, .large])
#else
        self
#endif
    }
    
    @ViewBuilder
    func minSizeRestrictionIfMacOS() -> some View {
#if os(macOS)
        frame(minWidth: 200, minHeight: 400)
#else
        self
#endif
    }
    
    @ViewBuilder
    func editButton() -> some View {
#if os(iOS)
        toolbar {
            EditButton()
        }
#else
        self
#endif
    }
    
    @ViewBuilder
    func iOSDefersSystemGesturesOnBottom(shouldDefer: Bool) -> some View {
#if os(iOS)
        if shouldDefer {
            defersSystemGestures(on: .bottom)
        } else {
            self
        }
#else
        self
#endif
    }
    
    func toolbarCloseButton(dismiss: DismissAction) -> some View {
        toolbar {
            Button(role: .close) {
                dismiss()
            }
        }
    }
    
    func toolbarConfirmationButton(
        dismiss: DismissAction,
        action: @escaping () -> Void = {}
    ) -> some View {
        toolbar {
            Button(role: .confirm) {
                action()
                dismiss()
            }
        }
    }
    

    func subscriptionSheet(isPresented: Binding<Bool>) -> some View {
        sheet(isPresented: isPresented) {
            NavigationStack {
                SubscriptionView()
                    .minSizeRestrictionIfMacOS()
            }
        }
    }
    
    func onSubscriptionGatedChange<T: Equatable>(
        _ showSubscriptionSheet: Binding<Bool>,
        of value: Binding<T>,
        requiresSubscription: @escaping (T) -> Bool = { _ in true },
        onAccepted: @escaping (T) -> Void = { _ in }
    ) -> some View {
        modifier(SubscriptionGatedChange(showSubscriptionSheet: showSubscriptionSheet, value: value, requiresSubscription: requiresSubscription, onAccepted: onAccepted))
    }
    
    func subscriptionIcon(show: Bool = true) -> some View {
        self.modifier(SubscriptionIconModifier(showIcon: show))
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

struct SubscriptionGatedChange<T: Equatable>: ViewModifier {
    @Binding var showSubscriptionSheet: Bool
    @Binding var value: T
    let requiresSubscription: (T) -> Bool
    let onAccepted: (T) -> Void

    @State private var isResetting = false
    
    @Environment(SubscriptionManager.self) private var subscription

    func body(content: Content) -> some View {
        content.onChange(of: value) { oldValue, newValue in
            guard !isResetting else { isResetting = false; return }
            guard !requiresSubscription(newValue) || subscription.isSubscribed else {
                isResetting = true
                value = oldValue
                showSubscriptionSheet.toggle()
                return
            }
            onAccepted(newValue)
        }
    }
}


struct SubscriptionIconModifier: ViewModifier {
    
    let showIcon: Bool
    
    @Environment(SubscriptionManager.self) private var subscription

    func body(content: Content) -> some View {
        HStack {
            if !subscription.isSubscribed, showIcon {
                Image(systemName: "lock.fill")
                    .font(.caption2.bold())
            }
            content
        }
    }
}

#if os(iOS)

import UIKit

typealias PlatformImage = UIImage
let platform = "iOS"

#elseif os(macOS)

import AppKit

typealias PlatformImage = NSImage
let platform = "macOS"

#endif

extension Image {
    
#if os(iOS)
    init(platformImage: PlatformImage) {
        self.init(uiImage: platformImage)
    }
    
#elseif os(macOS)
    init(platformImage: PlatformImage) {
        self.init(nsImage: platformImage)
    }
    
#endif
}
