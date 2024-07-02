//
//  Double.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/05/19.
//

import Foundation

extension Double {
    
    /// Converts a Double into string representation
    /// ```
    /// Convert 1.2345 to "1.23"
    /// ```
    func asNumberString(decimal: Int = 2) -> String {
        return String(format: "%.\(decimal)f", self)
    }
    
    /// Converts a Double
    /// ```
    /// Convert 1.2345 to 1.23
    /// ```
    func asNumber(decimal: Int  = 2) -> Double {
        return Double( asNumberString(decimal: decimal) ) ?? 0
    }
    
    /// converts a double into a currency with 2-6 decimal places
    /// ```
    /// 1234.567 -> 1234.56
    /// 0.1234567 -> 0.12
    /// ```
    private var formatter2: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false //使用分组分隔符
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2 //最小小数位数
        formatter.maximumFractionDigits = 2 //最大小数位数
        return formatter
    }
    
    /// converts a double into a currency with 2-6 decimal places
    /// ```
    /// 1234.567 -> $1,234.567
    /// 0.1234567 -> 0.123456
    /// ```
    private var currencyFormatter6: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true //使用分组分隔符
        formatter.numberStyle = .currency
        //formatter.locale = .current // <- defalut valse
        //formatter.currencyCode = "usd" // <- defalut currency 货币代码
        //formatter.currencySymbol = "$" // <- defalut currency symbol 货币符号
        formatter.minimumFractionDigits = 2 //最小小数位数
        formatter.maximumFractionDigits = 6 //最大小数位数
        return formatter
    }
    
    func asCurrencyWith6Decimals() -> String {
        let number = NSNumber(value: self)
        return currencyFormatter6.string(from: number) ?? "$0.00"
    }
    
    
    
    /// Convert a Double to a String with K, M, Bn, Tr abbreviations.
    /// ```
    /// Convert 12 to 12.00
    /// Convert 1234 to 1.23K
    /// Convert 123456 to 123.45K
    /// Convert 12345678 to 12.34M
    /// Convert 1234567890 to 1.23B
    /// Convert 123456789012 to 123.45B
    /// Convert 12345678901234 to 12.34T
    /// ```
    func formattedWithAbbreviations() -> String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""

        switch num {
        case 1_099_511_627_776...:
            let formatted = num / 1_099_511_627_776
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)T"
        case 1_073_741_824...:
            let formatted = num / 1_073_741_824
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)B"
        case 1_048_576...:
            let formatted = num / 1_048_576
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)M"
        case 1_024...:
            let formatted = num / 1_024
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)K"
        case 0...:
            return self.asNumberString(decimal: 0)

        default:
            return "\(sign)\(self)"
        }
    }
    
    func formattedWithAbbreviations2() -> (String, String) {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""

        var stringFormatted: String = "0"
        var symbol: String = "B"
        switch num {
        case 1_099_511_627_776...:
            let formatted = num / 1_099_511_627_776
            stringFormatted = formatted.asNumberString()
            symbol = "TB"
        case 1_073_741_824...:
            let formatted = num / 1_073_741_824
            stringFormatted = formatted.asNumberString()
            symbol = "GB"
        case 1_048_576...:
            let formatted = num / 1_048_576
            stringFormatted = formatted.asNumberString()
            symbol = "MB"
        case 1_024...:
            let formatted = num / 1_024
            stringFormatted = formatted.asNumberString()
            symbol = "KB"
        case 0...:
            stringFormatted = "\(self)"
        default:
            stringFormatted = "\(sign)\(self)"
        }
        
        return ("\(sign)\(stringFormatted)", symbol)

    }
    
}
