import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var monthlyInvestment: String = ""
    @State private var period: Double = 0
    @State private var rateOfReturn: Double = 0
    @State private var actualAmount: Double = 0
    @State private var timesRolledOver: Double = 0
    @State private var netReturn: Double = 0
    @FocusState private var isInputActive: Bool
    @EnvironmentObject var settingViewModel: SettingViewModel

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        HStack (spacing: 20) {
                            StatisticBoxView(title: "Actual Amount", value: String(format: "%.0f", actualAmount), isAmount: true)
                            StatisticBoxView(title: "Expected Amount", value: String(format: "%.0f", actualAmount + netReturn), isAmount: true)
                        }
                    }
                    Section {
                        HStack(alignment: .center) {
                            Spacer()
                            Text(formattedValue(netReturn))
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(netReturn > 0 ? .green : .red)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    } header: {
                        Text("Profit")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Section {
                        TextField("Enter Amount", text: $monthlyInvestment)
                            .keyboardType(.numberPad)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.center)
                            .focused($isInputActive)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.clear)
                            .cornerRadius(12)
                            .animation(.default.repeatCount(3, autoreverses: true).speed(6), value: isInputActive)
                    } header: {
                        Text("SIP Amount")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Section {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Period (Years)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.0f", period)).font(.headline)
                            }
                            Slider(value: $period, in: 0...40, step: 1)
                                .padding(.vertical)
                                .accentColor(.blue)
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Rate of Return (%)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.1f", rateOfReturn)).font(.headline)
                            }
                            Slider(value: $rateOfReturn, in: 0...30, step: 0.1)
                                .padding(.vertical)
                                .accentColor(.blue)
                        }
                    } footer: {
                        Text("Return can vary based on market trends")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .listRowSeparator(.hidden)
                    .onChange(of: monthlyInvestment) { _ in
                        calculateSIP()
                    }
                    .onChange(of: period) { _ in
                        calculateSIP()
                    }
                    .onChange(of: rateOfReturn) { _ in
                        calculateSIP()
                    }
                }
                .listStyle(.insetGrouped)
                .onAppear {
                    UIRefreshControl.appearance().tintColor = .blue
                    UIRefreshControl.appearance().attributedTitle = try? NSAttributedString(markdown: "")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Wealthify")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        settingViewModel.toggleTheme()
                    }) {
                        // Toggle icon based on current theme
                        Image(systemName: settingViewModel.currentTheme == .dark ? "sun.max.fill" : "moon.fill")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private func formattedValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol ?? "₹"
        return formatter.string(from: NSNumber(value: max(value > 0 ? value: 0, 0))) ?? "$0"
    }

    private func saveResults() {
        let newItem = Item(context: viewContext)
        newItem.timestamp = Date()
        newItem.actualAmount = "\(actualAmount)"
        newItem.netReturn = "\(netReturn)"
        newItem.period = "\(period)"
        newItem.rateOfReturn = "\(rateOfReturn)"
        newItem.timesRolledOver = "\(timesRolledOver)"
        
        do {
            try viewContext.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func calculateSIP() {
        guard let amount = Double(monthlyInvestment), period > 0, rateOfReturn > 0 else {
            actualAmount = 0
            timesRolledOver = 0
            netReturn = 0
            return
        }
        
        let periodMonthly = Double(period) * 12.0
        let rateOfReturnMonthly = rateOfReturn / 12.0 / 100.0
        
        actualAmount = amount * periodMonthly
        
        let futureAmount = futureSipValue(rateOfReturnMonthly, nper: periodMonthly, pmt: amount)
        netReturn = futureAmount - actualAmount
        timesRolledOver = actualAmount == 0 ? 0 : futureAmount / actualAmount
    }

    func futureSipValue(_ rate: Double, nper: Double, pmt: Double) -> Double {
        let futureValue = pmt * ((pow(1 + rate, nper) - 1) / rate) * (1 + rate)
        return futureValue
    }
}

struct StatisticBoxView: View {
    var title: String
    var value: String
    var isAmount: Bool
    
    private func formattedValue() -> String {
        if isAmount {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = Locale.current.currencySymbol ?? "₹"
            return formatter.string(from: NSNumber(value: max(Int(value) ?? 0, 0))) ?? "$0"
        } else {
            return "\(max(Int(value) ?? 0, 0))"
        }
    }
    
    var body: some View {
        VStack (spacing: 5) {
            Text(formattedValue())
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .font(.title)
                .fontWeight(.bold)
                .frame(height: 30)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(height: 20)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 60)
        .cornerRadius(10)
        .shadow(color: Color.primary.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}
