//
//  String.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 26/01/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import UIKit

extension Equatable {
    func oneOf(_ other: Self...) -> Bool {
        return other.contains(self)
    }
}

extension String: Type {
    
    func containsStrings(_ other: [String]) -> Bool {
        for string in other {
            if self.contains(string) {
                return true
            }
        }
        return false
    }
    
    func toDate(_ format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        
        return  dateFormatter.date(from: self)
    }
    
    func size(withFont font: UIFont) -> CGSize {
        let fontAttributes = [NSFontAttributeName: font as AnyObject]
        
        let size = (self as NSString).size(attributes: fontAttributes)
        
        return size
    }
    
    /**
     Get the Unmarkdown string
     */
    func nonMarkdownString()->String?{
        if let regexx = try? NSRegularExpression(pattern: "\\(/[^)]*\\)|[*\r\n_+=#:><&\\[\\]-]", options: .caseInsensitive) {
            let modString = regexx.stringByReplacingMatches(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.characters.count), withTemplate: "")
            return modString
        }
        return ""
    }
    
    /**
     Get HTML tag free string
     */
    func nonHTMLString() -> String {
        let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.caseInsensitive])
        
        let range = NSMakeRange(0, self.characters.count)
        var htmlLessString :String = regex.stringByReplacingMatches(in: self, options: [],
                                                                    range:range ,
                                                                    withTemplate: "")
        
        // Replace &quot; with ""
        htmlLessString = htmlLessString.replacingOccurrences(of: "&quot;", with: "\"")
        return htmlLessString
    }
    
    /**
     Returns digit only string
     */
    func digitsOnly() -> String{
        let stringArray = self.components(
            separatedBy: CharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        
        return newString
    }
    
    func addKerning(_ kernValue: CGFloat) -> NSAttributedString {
        let attributedString = NSAttributedString(string: self, attributes: [NSKernAttributeName: kernValue])
        return attributedString
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    /**
     getStringHeight calculates the height of a given string.
     - parameters:
     - String: The `String` to to calculate.
     - UIFont: The font to base the size of the text
     - CGFloat: The width of the text element
     - returns: Height `Float`
     */
    func getHeight(_ font: UIFont, width: CGFloat, readingOption options: NSStringDrawingOptions)->Float {
        let size = CGSize(width: width,height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        //MARK: Change made on branck debugging to fix heihght in RecipeCV
        paragraphStyle.lineBreakMode = .byWordWrapping;
        //paragraphStyle.lineBreakMode = .ByTruncatingTail
        let attributes = [NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRect(with: size, options: options, attributes: attributes, context:nil)
        
        return Float(rect.size.height)
    }
    
    /**
     numberOfLinesInString calculates the number of lines according to the sting height.
     - parameters:
     - String: The `String` to to calculate.
     - CGFloat: The width of the text element
     - CGFloat: The height of a given string
     - UIFont: The width of the text element
     - returns: Number of lines `Int`
     
     - seealso: `getStringHeight`, calculates the height of a given string.
     */
    func getNumberOfLines(_ labelWidth: CGFloat, labelHeight: CGFloat, font: UIFont) -> Int {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = labelHeight
        paragraphStyle.maximumLineHeight = labelHeight
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [String: AnyObject] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
        
        let constrain = CGSize(width: labelWidth, height: CGFloat(Float.infinity))
        
        let size = self.size(attributes: attributes)
        let stringWidth = size.width
        
        let numberOfLines = ceil(Double(stringWidth/constrain.width))
        
        return Int(numberOfLines)
    }
    
    /**
     getHeightFromNumberOfLines new height according to number of lines. Can be used in cases where we want to limit the number of lines of a given string
     - parameters:
     - CGFloat: The height of a given string
     - Int: The number of line of a given string
     - returns: Height `Float`
     
     - seealso: `getStringHeight`, calculates the height of a given string.
     - seealso: `numberOfLinesInString`, calculates the number of lines according to the sting height.
     */
    func getHeightFromNumberOfLines(_ height:CGFloat, lines:Int, linesWanted:Int)->Float {
        let heightPerLine = Float(Int(height) / lines)
        return (heightPerLine * Float(linesWanted))
    }
    
    /**
     Check if the Uppercase ratio is greater than Lowercase
     */
    func isUppercaseGreaterThanLowercase() -> Bool {
        let nonUpperCase = CharacterSet.uppercaseLetters.inverted
        let nonLowerCase = CharacterSet.lowercaseLetters.inverted
        let letters = self.components(separatedBy: nonUpperCase)
        let lowerLetters = self.components(separatedBy: nonLowerCase)
        let upper = letters.joined(separator: "")
        let lower = lowerLetters.joined(separator: "")
        
        return upper.characters.count > lower.characters.count
    }
}

extension NSAttributedString {
    func heightForWidth(_ width:CGFloat)->CGFloat{
        return self.boundingRect(with: CGSize(width: width,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).height
        //NSStringDrawingOptions.UsesFontLeading,
    }
}
