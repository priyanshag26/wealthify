import Foundation
import SwiftUI
import MessageUI
import SafariServices

struct SettingView: View {
    @EnvironmentObject var settingsViewModel: SettingViewModel
    @State private var themeType = AppUserDefaults.preferredTheme
    @State private var showSubscriptionFlow: Bool = false
    @State private var showMailView = false
    @State private var showShareSheet = false
    @State private var showSafariView = false
    
    var body: some View {
            Form {
                Section(header: Text("Preferences")) {
                   
                    HStack{
                        Text("Theme")
                        Spacer()
                        Picker("", selection: $themeType.onChange(themeChange)){
                            Text("System").tag(0)
                            Text("Light").tag(1)
                            Text("Dark").tag(2)
                        }
                        .fixedSize()
                        .pickerStyle(.segmented)
                    }
                }
                
                Section(header: Text(""),
                        footer: SettingsRowView(name: "App Version", content: "\(Bundle.main.versionNumber).\(Bundle.main.buildNumber)")
                ) {
                }
            }
            .navigationTitle("Settings")
    }
    
    func themeChange(_ tag: Int){
        settingsViewModel.changeAppTheme(theme: tag)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(SettingViewModel())
    }
}


struct SettingsLabelView: View {
    
    var labelText: String
    var labelImage: String
    
    var body: some View {
        HStack {
            Text(labelText.uppercased())
            Spacer()
            Image(systemName: labelImage )
                .font(.headline)
        }
    }
}


struct SettingsRowView: View {
    
    var name: String
    var content: String? = nil
    
    var body: some View {
        VStack {
            HStack{
                Text(LocalizedStringKey(name)).foregroundColor(.gray)
                Spacer()
                if content != nil {
                    Text(content!)
                }
            }
        }
    }
}


extension Bundle {
    
    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }
    
    var bundleId: String {
        return bundleIdentifier!
    }
    
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
    
}


struct SafariView: UIViewControllerRepresentable {
    let url: URL
    @Binding var isShowing: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor()
        return safariViewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        isShowing = false
    }
}
