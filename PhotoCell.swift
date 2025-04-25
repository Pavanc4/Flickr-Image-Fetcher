
//  PhotoCell.swift
//  FlickrImageFetcher
//
//  Created by PavanAvvaru on 2025-04-24.
//

import UIKit
import Foundation

class PhotoCell: UICollectionViewCell {
    static let identifier = "PhotoCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with urlString: String) {
        // Check if the image is already cached
        if let cachedImage = ImageCache.shared.get(forKey: urlString) {
            imageView.image = cachedImage
            return
        }

        guard let url = URL(string: urlString) else { return }
        
        // Download image if not cached
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else { return }
            
            // Cache the image after downloading
            ImageCache.shared.set(image, forKey: urlString)
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }.resume()
    }
}
