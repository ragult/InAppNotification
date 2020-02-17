//
//  AlbumsViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class AlbumsViewController: UIViewController {
    @IBOutlet var albumTItle: UILabel!
    @IBOutlet var usersLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var albumsCollectionView: UICollectionView!
    @IBOutlet var plusFloatingButton: UIButton!

    var dummyImages = ["https://www.gstatic.com/webp/gallery/3.jpg", "https://www.gstatic.com/webp/gallery/1.jpg", "https://www.gstatic.com/webp/gallery/1.jpg", "https://www.gstatic.com/webp/gallery/2.jpg", "https://www.gstatic.com/webp/gallery/3.jpg", "https://www.gstatic.com/webp/gallery/5.jpg", "https://www.gstatic.com/webp/gallery/3.jpg", "https://www.gstatic.com/webp/gallery/5.jpg", "https://www.gstatic.com/webp/gallery/4.jpg", "https://www.gstatic.com/webp/gallery/1.jpg", "https://www.gstatic.com/webp/gallery/2.jpg", "https://www.gstatic.com/webp/gallery/3.jpg", "https://www.gstatic.com/webp/gallery/4.jpg", "https://www.gstatic.com/webp/gallery/3.jpg"]
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = albumsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1.5
        layout.minimumInteritemSpacing = 0.5
        layout.sectionInset = UIEdgeInsets(top: 4, left: 2, bottom: 4, right: 2)
        layout.itemSize = CGSize(width: albumsCollectionView.frame.width / 3 - 2, height: 126)
    }

    @IBAction func plusFloatingButtonAction(_: Any) {}
}

extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dummyImages.count
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell", for: indexPath) as! AlbumCollectionViewCell
        if let imageUrl = URL(string: dummyImages[indexPath.row]) {
            cell.photoView.af_setImage(withURL: imageUrl)
        }
        return cell
    }
}
