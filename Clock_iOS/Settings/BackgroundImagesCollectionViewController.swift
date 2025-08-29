//
//  BackgroundImagesCollectionViewController.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 5.5.2018.
//  Copyright © 2018 Bergþór Þrastarson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "imageCell"

class BackgroundImagesCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var images = [UIImage]()
    var imageNames = [String]() // To track which images are default vs custom
    private var hasSetupLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the custom cell
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Ensure scrolling is enabled
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.showsVerticalScrollIndicator = false
        
        // Set up navigation
        self.title = "Background Images"
        
        // Add button to add new images
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImageTapped))
        navigationItem.rightBarButtonItem = addButton
        
        // Load default images
        loadDefaultImages()
        
        // Load custom images
        loadCustomImages()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Setup collection view layout after we have proper frame sizes (only once)
        if !hasSetupLayout && collectionView.frame.height > 0 {
            setupCollectionViewLayout()
            hasSetupLayout = true
        }
    }
    
    private func setupCollectionViewLayout() {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            // Set horizontal scrolling
            layout.scrollDirection = .horizontal
            
            let padding: CGFloat = 16
            let containerHeight = collectionView.frame.height
            let itemHeight = max(containerHeight - (padding * 2), 100) // Minimum height of 100
            let itemWidth = itemHeight * (4.0/3.0) // iPad aspect ratio (4:3)
            
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            
            // Invalidate layout to apply changes
            layout.invalidateLayout()
        }
    }
    
    private func loadDefaultImages() {
        // Default background images from the main app
        let defaultImageNames = ["gos", "irland", "herad", "eyvindara", "plants", "leaves", "straws"]
        
        for imageName in defaultImageNames {
            if let image = UIImage(named: imageName) {
                images.append(image)
                imageNames.append(imageName) // Mark as default
            }
        }
    }
    
    private func loadCustomImages() {
        // Load custom images from Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesPath = documentsPath.appendingPathComponent("CustomBackgroundImages")
        
        do {
            let imageFiles = try FileManager.default.contentsOfDirectory(at: imagesPath, includingPropertiesForKeys: nil)
            
            for imageFile in imageFiles {
                if let imageData = try? Data(contentsOf: imageFile),
                   let image = UIImage(data: imageData) {
                    images.append(image)
                    imageNames.append(imageFile.lastPathComponent) // Mark as custom
                }
            }
        } catch {
            print("No custom images directory found, creating one...")
            try? FileManager.default.createDirectory(at: imagesPath, withIntermediateDirectories: true)
        }
    }
    
    @objc private func addImageTapped() {
        presentImagePicker()
    }
    
    private func presentImagePicker() {
        let alert = UIAlertController(title: "Bæta við mynd", message: "Veldu hvannig þú vilt bæta við mynd:", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Taka mynd", style: .default) { _ in
                self.showImagePicker(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Velja úr myndasafni", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Hætta við", style: .cancel)
        
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func addImage(image:UIImage) {
        images.append(image)
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
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
    
        // Configure the cell with image
        let image = images[indexPath.item]
        let imageName = imageNames[indexPath.item]
        let isDefaultImage = !imageName.contains(".") // Default images don't have file extensions
        
        cell.configure(with: image, name: imageName, isDefault: isDefaultImage)
    
        return cell
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            return
        }
        
        // Save image to documents directory
        saveCustomImage(image)
        
        // Add to arrays
        images.append(image)
        let fileName = "custom_\(Date().timeIntervalSince1970).jpg"
        imageNames.append(fileName)
        
        // Reload collection view
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: self.images.count - 1, section: 0)
            self.collectionView.insertItems(at: [indexPath])
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func saveCustomImage(_ image: UIImage) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesPath = documentsPath.appendingPathComponent("CustomBackgroundImages")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: imagesPath, withIntermediateDirectories: true)
        
        // Save image
        let fileName = "custom_\(Date().timeIntervalSince1970).jpg"
        let filePath = imagesPath.appendingPathComponent(fileName)
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: filePath)
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageName = imageNames[indexPath.item]
        let isDefaultImage = !imageName.contains(".")
        
        if !isDefaultImage {
            // Show options for custom images (delete)
            let alert = UIAlertController(title: "Mynd valið", message: "Hvað viltu gera við þessa mynd?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Eyða", style: .destructive) { _ in
                self.deleteCustomImage(at: indexPath)
            }
            
            let cancelAction = UIAlertAction(title: "Hætta við", style: .cancel)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            // iPad support
            if let popover = alert.popoverPresentationController {
                let cell = collectionView.cellForItem(at: indexPath)
                popover.sourceView = cell
                popover.sourceRect = cell?.bounds ?? CGRect.zero
            }
            
            present(alert, animated: true)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    private func deleteCustomImage(at indexPath: IndexPath) {
        let imageName = imageNames[indexPath.item]
        
        // Delete from file system
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesPath = documentsPath.appendingPathComponent("CustomBackgroundImages")
        let filePath = imagesPath.appendingPathComponent(imageName)
        
        try? FileManager.default.removeItem(at: filePath)
        
        // Remove from arrays
        images.remove(at: indexPath.item)
        imageNames.remove(at: indexPath.item)
        
        // Update collection view
        collectionView.deleteItems(at: [indexPath])
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
