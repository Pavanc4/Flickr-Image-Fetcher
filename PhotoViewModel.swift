
//  PhotoViewModel.swift
//  FlickrImageFetcher
//
//  Created by PavanAvvaru on 2025-04-24.
//

// PhotoViewModel.swift
import Foundation

class PhotoViewModel {
    private(set) var images: [APOD] = []
    var onImagesUpdated: (() -> Void)?
    
    func fetchImages() {
        let urlString = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&count=10"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode([APOD].self, from: data)
                self?.images = decodedResponse
                DispatchQueue.main.async {
                    self?.onImagesUpdated?()
                }
            } catch {
                print("Failed to decode JSON:", error)
            }
        }.resume()
    }
}
