
import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    
    @Published var theme: ColorScheme? = nil

    @Published var logo: UIImage? {
        didSet {
            let pngRepresentation = logo?.pngData()
            UserDefaults.standard.set(pngRepresentation, forKey: "logo")
        }
    }
    
    init(){
        theme = getTheme()
        
        if let data = UserDefaults.standard.data(forKey: "logo"){
            self.logo =  UIImage.init(data:data) ?? UIImage(systemName: "applelogo")!.withTintColor(UIColor.label)
        }
                
        theme = getTheme()
    }
    
    func getTheme() -> ColorScheme? {
        let theme = AppUserDefaults.preferredTheme
        var _theme: ColorScheme? = nil
        if theme == 0 {
            _theme = nil
        }else if theme == 1 {
            _theme = ColorScheme.light
        }else {
            _theme = ColorScheme.dark
        }
        return _theme
    }
    
    func changeAppTheme(theme: Int){
        AppUserDefaults.preferredTheme = theme
        self.theme = getTheme()
    }
    
    
}
