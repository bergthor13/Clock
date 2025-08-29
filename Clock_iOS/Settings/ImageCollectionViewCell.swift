//
//  ImageCollectionViewCell.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 13/01/2019.
//  Copyright © 2019 Bergþór Þrastarson. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let typeIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Setup image view
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        // Setup name label
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // Setup type indicator (small circle)
        typeIndicator.layer.cornerRadius = 4
        typeIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Image view constraints - fills entire cell
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Name label constraints - hidden but kept for type indicator positioning
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: typeIndicator.leadingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            nameLabel.heightAnchor.constraint(equalToConstant: 0), // Hidden
            
            // Type indicator constraints - positioned in top right corner
            typeIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            typeIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            typeIndicator.widthAnchor.constraint(equalToConstant: 12),
            typeIndicator.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        // Setup cell appearance
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        
        // iOS version compatibility
        if #available(iOS 13.0, *) {
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            contentView.backgroundColor = UIColor.systemBackground
        } else {
            contentView.layer.borderColor = UIColor.lightGray.cgColor
            contentView.backgroundColor = UIColor.white
        }
    }
    
    func configure(with image: UIImage, name: String, isDefault: Bool) {
        imageView.image = image
        nameLabel.text = name
        nameLabel.isHidden = true // Hide the name label
        
        // Set type indicator color
        if #available(iOS 13.0, *) {
            if isDefault {
                typeIndicator.backgroundColor = UIColor.systemBlue
            } else {
                typeIndicator.backgroundColor = UIColor.systemGreen
            }
        } else {
            if isDefault {
                typeIndicator.backgroundColor = UIColor.blue
            } else {
                typeIndicator.backgroundColor = UIColor.green
            }
        }
        
        // Update text color based on iOS version
        if #available(iOS 13.0, *) {
            nameLabel.textColor = UIColor.label
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            contentView.backgroundColor = UIColor.systemBackground
        } else {
            nameLabel.textColor = UIColor.black
            contentView.layer.borderColor = UIColor.lightGray.cgColor
            contentView.backgroundColor = UIColor.white
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        typeIndicator.backgroundColor = nil
    }
}
