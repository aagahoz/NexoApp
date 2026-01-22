//
//  GradientBackgroundView.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 22.01.2026.
//

import UIKit

final class GradientBackgroundView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setupGradient()
        layer.insertSublayer(gradientLayer, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGradient() {
        let baseDark = UIColor(red: 10/255, green: 11/255, blue: 14/255, alpha: 1)
        let midLift  = UIColor(red: 22/255, green: 24/255, blue: 30/255, alpha: 1)
        let softGlow = UIColor(red: 28/255, green: 30/255, blue: 38/255, alpha: 0.85)
        let deep     = UIColor(red: 8/255,  green: 9/255,  blue: 12/255, alpha: 1)

        gradientLayer.colors = [
            baseDark.cgColor,
            midLift.cgColor,
            softGlow.cgColor,
            deep.cgColor
        ]
        gradientLayer.locations = [0.0, 0.35, 0.6, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.15, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.85, y: 1.0)
        gradientLayer.opacity = 0.98
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
