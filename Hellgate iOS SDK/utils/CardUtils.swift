import Foundation

func isValidLUHN(_ cardNumber: String) -> Bool {
    guard cardNumber.isEmpty == false else { return false }
        
    var isOdd = true
    var sum = 0
    
    for index in stride(from: cardNumber.count-1, through: 0, by: -1) {
        let c = cardNumber[cardNumber.index(cardNumber.startIndex, offsetBy: index)]
        
        guard c.isNumber, var digitInteger = Int(String(c), radix: 10) else { return false }
        
        isOdd = !isOdd
        
        if (isOdd) {
            digitInteger *= 2
        }
        
        if (digitInteger > 9) {
            digitInteger -= 9
        }
        
        sum += digitInteger
    }
    
    return sum % 10 == 0
}
