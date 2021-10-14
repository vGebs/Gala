//
//  UIImage.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-19.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

extension UIImage {
    func compressToHeic(quality: CGFloat) -> AnyPublisher<Data, Error> {
        return Future<Data, Error> { promise in
            do {
                let data = try self.heicData(compressionQuality: quality)
                promise(.success(data))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func jpeg(_ quality: CGFloat) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
    
    func compressToJpeg(quality: CGFloat) -> AnyPublisher<UIImage, Error> {
        
        enum CompressError: Error { case couldNotCompressJpeg; case couldNotConvertToUIImage }
        
        return Future<UIImage, Error> { promise in
            
            if let data = self.jpegData(compressionQuality: quality) {
                if let imgg = UIImage(data: data) {
                    promise(.success(imgg))
                } else {
                    promise(.failure(CompressError.couldNotConvertToUIImage))
                }
            } else {
                promise(.failure(CompressError.couldNotCompressJpeg))
            }
            
        }.eraseToAnyPublisher()
    }
    
    
    enum HEICError: Error {
        case heicNotSupported
        case cgImageMissing
        case couldNotFinalize
    }
    
    private func heicData(compressionQuality: CGFloat) throws -> Data {
        let data = NSMutableData()
        guard let imageDestination =
                CGImageDestinationCreateWithData(
                    data, AVFileType.heic as CFString, 1, nil
                )
        else {
            throw HEICError.heicNotSupported
        }
        
        guard let cgImage = self.cgImage else {
            throw HEICError.cgImageMissing
        }
        
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        
        CGImageDestinationAddImage(imageDestination, cgImage, options)
        guard CGImageDestinationFinalize(imageDestination) else {
            throw HEICError.couldNotFinalize
        }
        
        return data as Data
    }
    
    static func convert(from ciImage: CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}

