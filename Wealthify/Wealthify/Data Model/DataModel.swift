//
//  DataModel.swift
//  Wealthify
//
//  Created by Priyansh on 04/02/25.
//

import Foundation

struct Calculate {
    var monthlyInvestment: Double
    var period: Double
    var rateOfReturn: Double
    var actualAmount: Double = 0.0
    var timesRolledOver: Int = 0
    var netReturn: Double = 0.0

    private func futureSipValue(rateOfReturnMonthly: Double, nper: Double, pmt: Double) -> Double {
        let factor = pow(1 + rateOfReturnMonthly, nper) - 1
        let futureValue = pmt * factor / rateOfReturnMonthly
        return futureValue
    }

    mutating func calculateSIP() {
        guard period > 0, rateOfReturn > 0 else {
            actualAmount = 0
            timesRolledOver = 0
            netReturn = 0
            return
        }

        let periodMonthly = period * 12.0
        let rateOfReturnMonthly = rateOfReturn / 12.0 / 100.0

        actualAmount = monthlyInvestment * periodMonthly
        let futureAmount = futureSipValue(rateOfReturnMonthly: rateOfReturnMonthly, nper: periodMonthly, pmt: monthlyInvestment)

        netReturn = futureAmount - actualAmount
        timesRolledOver = actualAmount == 0 ? 0 : Int(futureAmount / actualAmount)
    }
}
