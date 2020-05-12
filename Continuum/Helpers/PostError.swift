//
//  PostError.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation

enum PostError: LocalizedError {
    
    case ckError(Error)
    case unableToUnwrap
    
    var localizedDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .unableToUnwrap:
            return "Unable to decode data from Cloud"
        }
    }
}
