//
//  FaerdCollectionViewController.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 24/01/2019.
//  Copyright © 2019 Bergþór Þrastarson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "faerdCell"

class FaerdCollectionViewController: UICollectionViewController {

    let imageURLs = [
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/vestfirdir.png",
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/nordurland.png",
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/nordausturland.png",
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/vesturland.png",
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/halendi.png",
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/austurland.png",
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/sudvesturland.png",
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/sudurland.png",
        "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/sudausturland.png",
    ]
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setja svartan bakgrunn
        self.collectionView.backgroundColor = UIColor.black
        
        for _ in imageURLs {
            images.append(UIImage())
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(FaerdCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FaerdCollectionViewCell
        if images[indexPath.row].size.width == 0 {
            let url = URL(string: imageURLs[indexPath.row])!
            Downloader.downloadImage(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    let dlImage = UIImage(data: data)
                    self.images[indexPath.row] = dlImage!
                    cell.imageView.image = dlImage
                }
            }
        } else {
            cell.imageView.image = images[indexPath.row]
        }
        
        return cell
    }
    


}

extension FaerdCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = (collectionView.bounds.width/3.0)
        let yourHeight = (collectionView.bounds.height)
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
