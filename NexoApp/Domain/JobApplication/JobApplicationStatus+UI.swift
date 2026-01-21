//
//  JobApplicationStatus+UI.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 17.01.2026.
//

import UIKit

extension JobApplicationStatus {

    var displayTitle: String {
        switch self {
        case .notApplied:
            return "Not Applied"
        case .applied:
            return "Applied"
        case .reviewing:
            return "Reviewing"
        case .rejected:
            return "Rejected"
        case .accepted:
            return "Accepted"
        }
    }

    var displayColor: UIColor {
        switch self {
        case .notApplied:
            return .systemGray
        case .applied:
            return .systemBlue
        case .reviewing:
            return .systemOrange
        case .rejected:
            return .systemRed
        case .accepted:
            return .systemGreen
        }
    }
    
    var symbolName: String {
        switch self {
        case .notApplied:
            return "circle"
        case .applied:
            return "paperplane"
        case .reviewing:
            return "hourglass"
        case .accepted:
            return "checkmark.circle"
        case .rejected:
            return "xmark.circle"
        }
    }
}
