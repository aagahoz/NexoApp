//
//  JobCell.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

final class JobCell: UITableViewCell {
    
    static let reuseIdentifier = "JobCell"
    
    func configure(with job: Job) {
        textLabel?.text = job.title
    }
}
