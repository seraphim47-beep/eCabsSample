//
//  viewExtension.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.
//

import UIKit

extension UIView {
    
    func addBorderTop(size: CGFloat, color: UIColor, opacity: Float, margin: CGFloat) {
        removeBorder(name: "top")
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color.withAlphaComponent(CGFloat(opacity))
        border.accessibilityIdentifier = "border_top"
        
        addSubview(border)
        
        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            border.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            border.topAnchor.constraint(equalTo: topAnchor),
            border.heightAnchor.constraint(equalToConstant: size)
        ])
    }
    
    func removeBorder(name: String) {
        let identifier = "border_\(name)"
        
        subviews
            .filter { $0.accessibilityIdentifier == identifier }
            .forEach { $0.removeFromSuperview() }
    }
    
    
}
