//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let error = NSError(domain: "STSocialError", code: 43, userInfo: [NSLocalizedDescriptionKey:"ashdalsdad", NSLocalizedRecoverySuggestionErrorKey: "help"])

let _err = error as Error
error.localizedRecoverySuggestion

_err.localizedDescription
 let g = _err as NSError
g.localizedRecoverySuggestion