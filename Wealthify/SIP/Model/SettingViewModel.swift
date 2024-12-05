import SwiftUI

class SettingViewModel: ObservableObject {
    @Published var currentTheme: ColorScheme = .light

    func toggleTheme() {
        currentTheme = currentTheme == .light ? .dark : .light
    }

    func getTheme() -> ColorScheme {
        return currentTheme
    }
}
