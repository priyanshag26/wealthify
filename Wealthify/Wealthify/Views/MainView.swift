import SwiftUI

struct MainView: View {
    @State private var monthlyInvestment: String = ""
    @State private var period: Double = 0
    @State private var rateOfReturn: Double = 0
    @State private var actualAmount: Double = 0
    @State private var timesRolledOver: Double = 0
    @State private var netReturn: Double = 0
    @State private var calculate = Calculate(monthlyInvestment: 0, period: 0, rateOfReturn: 0)
    @Environment(\.colorScheme) private var colorScheme
    @State private var isDarkMode = false
    
    var body: some View {
        VStack (spacing: 8) {
            HStack{
                Text ("Wealthify")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.darkCanvas))
                Spacer()
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.title)
                        .foregroundColor(isDarkMode ? .yellow : Color(.darkCanvas))
                }
            }
            .frame(width: 350)
            Divider()
            VStack {
                HStack(spacing: 20) {
                    StatisticBoxView(actualAmount: actualAmount, netReturn: netReturn)
                }
                .padding(25)
                VStack {
                    Text("PROFIT")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.darkCanvas))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                    Text(formattedValue(netReturn))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(.darkCanvas))
                        .frame(width: 360, height: 60)
                        .background(Color(.lightCanvas))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 5) {
                    Text("SIP AMOUNT")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.darkCanvas))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                    TextField("Enter Amount", text: $monthlyInvestment)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(.darkCanvas))
                        .padding(10)
                        .frame(width: 360, height: 60)
                        .background(Color(.lightCanvas))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .onChange(of: monthlyInvestment, { oldValue, newValue in
                            recalculateSIP()
                        })
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 25)
                
                VStack {
                    HStack {
                        Text("Period (Years)")
                            .font(.footnote)
                            .foregroundStyle(Color(.darkCanvas))
                        Spacer()
                        Text(String(format: "%.0f", period))
                            .font(.headline)
                            .foregroundStyle(Color(.darkCanvas))
                    }
                    Slider(value: $period, in: 0...40, step: 1)
                        .padding(.vertical)
                        .accentColor(Color(.darkCanvas))
                        .onChange(of: period, { oldValue, newValue in
                            recalculateSIP()
                        })
                    HStack {
                        Text("Rate of Return (%)")
                            .font(.footnote)
                            .foregroundStyle(Color(.darkCanvas))
                        Spacer()
                        Text(String(format: "%.1f", rateOfReturn))
                            .font(.headline)
                            .foregroundStyle(Color(.darkCanvas))
                    }
                    Slider(value: $rateOfReturn, in: 0...40, step: 1)
                        .padding(.vertical)
                        .accentColor(Color(.darkCanvas))
                        .onChange(of: rateOfReturn, { oldValue, newValue in
                            recalculateSIP()
                        })
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 30)
                .frame(width: 360, height: 240)
                .background(Color(.lightCanvas))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
            }
        }
        .padding(.vertical, 80)
        .ignoresSafeArea()
        .background(Color(.lightCanvas).opacity(0.5))
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private func formattedValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol ?? "₹"
        return formatter.string(from: NSNumber(value: max(value, 0))) ?? "$0"
    }
    
    private func recalculateSIP() {
        guard let monthlyAmount = Double(monthlyInvestment) else { return }
        
        calculate.monthlyInvestment = monthlyAmount
        calculate.period = period
        calculate.rateOfReturn = rateOfReturn
        
        calculate.calculateSIP()
        
        actualAmount = calculate.actualAmount
        netReturn = calculate.netReturn
        timesRolledOver = Double(calculate.timesRolledOver)
    }
}

struct StatisticBoxView: View {
    var actualAmount: Double
    var netReturn: Double
    
    private func formattedValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol ?? "₹"
        return formatter.string(from: NSNumber(value: max(value, 0))) ?? "$0"
    }
    
    var body: some View {
        VStack(spacing: 5) {
            HStack (spacing: 40){
                VStack (spacing: 10) {
                    Text(formattedValue(actualAmount))
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(.darkCanvas))
                    Text("Amount Invested")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.darkCanvas))
                }
                .frame(width: 160, height: 100)
                .background(Color(.lightCanvas))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack (spacing: 10) {
                    Text(formattedValue(actualAmount + netReturn))
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(.darkCanvas))
                    
                    Text("Expected Returns")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.darkCanvas))
                }
                .frame(width: 160, height: 100)
                .background(Color(.lightCanvas))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .frame(width: 420, height: 100)
        }
    }
}

#Preview {
    MainView()
}
