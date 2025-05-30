//
//  ContentView.swift
//  Calculator
//
//  Created by Beyza Tapan on 30.05.2025.
//



import SwiftUI

struct CalcButton: View {
    let title: String
    var action: () -> Void
    
    private var isOperator: Bool { ["+", "−", "×", "÷", "="].contains(title) }
    private var isCalLogo: Bool   { title == "CAL" }
    private var isAC: Bool        { title == "AC" }
    
    private var fillColor: Color {
        if isCalLogo { return .gray.opacity(0.2) }
        if isAC      { return .red.opacity(0.8) }
        return isOperator ? .orange : .gray.opacity(0.2)
    }
    
    @ViewBuilder
    private var label: some View {
        if isCalLogo {
            Image("calculatorButton")
                .resizable()
                .scaledToFit()
                .padding(14)
        } else if isAC {
            Image(systemName: "delete.left")
                .resizable()
                .scaledToFit()
                .padding(18)
                .foregroundColor(.white)
        } else {
            Text(title)
                .font(.title)
        }
    }
    
    var body: some View {
        Button(action: action) {
            label
                .frame(width: 70, height: 70)
                .foregroundColor(isOperator || isAC ? .white : .primary)
                .background(fillColor)
                .clipShape(Circle())
        }
    }
}


struct ContentView: View {
    @State private var display: String = "0"
    
    private let grid: [[String]] = [
        ["AC", "+/−", "%", "÷"],
        ["7",   "8",  "9", "×"],
        ["4",   "5",  "6", "−"],
        ["1",   "2",  "3", "+"],
        ["CAL", "0",  ",", "="]
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(display)
                .font(.system(size: 64, weight: .light, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(grid, id: \.self) { rowLabels in
                    HStack(spacing: 12) {
                        ForEach(rowLabels, id: \.self) { label in
                            CalcButton(title: label) {
                                handleTap(label)
                            }
                        }
                    }
                }
            }
            .padding(.all, 16)
            .padding(.bottom, 20)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func handleTap(_ label: String) {
        switch label {
        case "AC":
            if display.count > 1 {
                display.removeLast()
            } else{
                display = "0"
            }
        
        
        case ",":
            if !display.contains(",") {
                display += ","
            }
        case "CAL":
            display = display + ""
        case "=":
            let expr = display
                .replacingOccurrences(of: ",", with: ".")
                .replacingOccurrences(of: "×", with: "*")
                .replacingOccurrences(of: "÷", with: "/")
                .replacingOccurrences(of: "−", with: "-")
            if let result = NSExpression(format: expr)
                .expressionValue(with: nil, context: nil) as? NSNumber {
                let text = String(format: "%g", result.doubleValue)
                display = text.replacingOccurrences(of: ".", with: ",")
            }
            
        case "+/−":
                   
                    if let last = display.last, last.isNumber {
                        let ops: Set<Character> = ["+", "−", "×", "÷"]
                        if let idx = display.lastIndex(where: { ops.contains($0) }) {
                            let start = display.index(after: idx)
                            let number = String(display[start...])
                            let flipped = number.hasPrefix("-") ?
                                String(number.dropFirst()) : "(" + "-" + number + ")"
                            display = String(display[..<start]) + flipped
                        } else {
                            let number = display
                            let flipped = number.hasPrefix("-") ?
                                String(number.dropFirst()) : "(" + "-" + number + ")"
                            display = flipped
                        }
                    }
        case "%":
                   let ops: Set<Character> = ["+", "−", "×", "÷"]
                   if let idx = display.lastIndex(where: { ops.contains($0) }) {
                       let start = display.index(after: idx)
                       var number = String(display[start...])
                       // Nokta-virgül dönüşümü
                       let normalized = number.replacingOccurrences(of: ",", with: ".")
                       if let value = Double(normalized) {
                           let percent = value / 100
                           let formatted = String(format: "%g", percent)
                               .replacingOccurrences(of: ".", with: ",")
                           display = String(display[..<start]) + formatted
                       }
                   } else {
                       var number = display
                       let normalized = number.replacingOccurrences(of: ",", with: ".")
                       if let value = Double(normalized) {
                           let percent = value / 100
                           let formatted = String(format: "%g", percent)
                               .replacingOccurrences(of: ".", with: ",")
                           display = formatted
                       }
                   }
        default:
            
            if display == "0" || ["+", "−", "×", "÷"].contains(display) {
                display = label
            } else {
                display += label
            }
        }
    }
}


#Preview {
    ContentView()
}
