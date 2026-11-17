//
//  AvatarLoader.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

// **EN:** An actor dedicated to asynchronous avatar loading. It uses `URLSession`, an `NSCache` indexed by URL, and a table of in-flight tasks. This allows it to reuse previously loaded images and share a single request among concurrent calls for the same URL.

// **IT:** È un actor dedicato al caricamento asincrono degli avatar. Utilizza `URLSession`, una `NSCache` indicizzata per URL e una tabella di task in corso. In questo modo può riutilizzare immagini già caricate e condividere una stessa richiesta tra chiamate concorrenti per lo stesso URL.

import UIKit

actor AvatarLoader {

    private let session: URLSession
    private let cache = NSCache<NSURL, UIImage>()

    private var tasks: [URL: Task<UIImage?, Never>] = [:]

    init(session: URLSession = .shared) {
        self.session = session
    }

    func loadImage(from url: URL) async -> UIImage? {
        let cacheKey = url as NSURL

        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }

        if let existingTask = tasks[url] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> {
            do {
                let (data, response) = try await session.data(from: url)

                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode),
                      let image = UIImage(data: data) else {
                    return nil
                }

                return image
            } catch {
                return nil
            }
        }

        tasks[url] = task

        let image = await task.value
        tasks[url] = nil

        if let image {
            cache.setObject(image, forKey: cacheKey)
        }

        return image
    }
}
