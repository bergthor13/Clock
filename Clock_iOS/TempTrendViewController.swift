//
//  TempTrendViewController.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 27/01/2019.
//  Copyright © 2019 Bergþór Þrastarson. All rights reserved.
//

import UIKit

class TempTrendViewController: UIViewController {
    weak var tempTrend: UIImage!
    
    var imageView: UIImageView!
    func initializeViews() {
        self.view.backgroundColor = UIColor.black

        self.imageView = UIImageView(frame: self.view.frame)
        self.imageView.contentMode = .scaleAspectFit
    }
    
    func addSubviews() {
        self.view.addSubview(self.imageView)
    }
    
    func addTapRecognizers() {
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.didTapImage(_:)))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
    }
    
    @objc func didTapImage(_:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Downloader.downloadImage(from: URL(string: "http://brunnur.vedur.is/athuganir/sjalfvirkar/strau/t_1d.gif")!) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let image = UIImage(data: data)
            DispatchQueue.main.async() {
                self.imageView.image = image
            }

        }
        initializeViews()
        self.addSubviews()
        self.addTapRecognizers()
    }
}
