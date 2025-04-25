
//  ViewController.swift
//  FlickrImageFetcher
//
//  Created by PavanAvvaru on 2025-04-24.
//

import UIKit

class ViewController: UIViewController {
    
    private let viewModel = PhotoViewModel()
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "NASA APOD"
        view.backgroundColor = .white
        
        setupCollectionView()
        bindViewModel()
        viewModel.fetchImages() // Trigger fetching images
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 2 - 10, height: view.frame.width / 2 - 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    private func bindViewModel() {
        viewModel.onImagesUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        let apod = viewModel.images[indexPath.item]
        cell.configure(with: apod, viewModel: viewModel)
        return cell
    }
}

// MARK: - ImageCell

class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with apod: APOD, viewModel: PhotoViewModel) {
        // Check cache for image
        if let cachedImage = ImageCache.shared.get(forKey: apod.imageURL) {
            imageView.image = cachedImage
            return
        }
        
        // Fetch image if not cached
        guard let url = URL(string: apod.imageURL) else { return }
        
        // Fetch image asynchronously
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            // Cache the image
            ImageCache.shared.set(image, forKey: apod.imageURL)
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }.resume()
    }
}


