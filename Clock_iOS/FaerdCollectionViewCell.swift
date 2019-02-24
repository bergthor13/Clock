//
//  FaerdCollectionViewCell.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 24/01/2019.
//  Copyright © 2019 Bergþór Þrastarson. All rights reserved.
//

import UIKit

class FaerdCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addViews()
    }
    
    func addViews() {
        imageView.frame = self.contentView.frame
        self.contentView.insertSubview(imageView, at: 100)
    }
}
