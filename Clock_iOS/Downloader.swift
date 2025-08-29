//
//  Downloader.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 24/01/2019.
//  Copyright © 2019 Bergþór Þrastarson. All rights reserved.
//

import Foundation

class Downloader {
    static func downloadImage(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        // Búa til sérstaka URLSession með delegation til að meðhöndla SSL vandamál
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: InsecureSessionDelegate(), delegateQueue: nil)
        
        session.dataTask(with: url, completionHandler: completion).resume()
    }
    
}
