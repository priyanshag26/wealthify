import Foundation
import SwiftUI
import MessageUI
import SafariServices

struct SettingView: View {
    @EnvironmentObject var settingsViewModel: SettingViewModel
    @State private var themeType = AppUserDefaults.preferredTheme
    
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
