//
//  AllExtensions.swift
//  SkillLinkr
//
//  Created by Christian on 21.07.24.
//

import Foundation
import SwiftUI
import UIKit

extension Image {
    func jpgData(compressionQuality: CGFloat) -> Data? {
        // Convert SwiftUI Image to UIImage
        let uiImage = self.asUIImage()
        
        // Get JPEG data from UIImage
        return uiImage.jpegData(compressionQuality: compressionQuality)
    }
    
    // Helper function to convert SwiftUI Image to UIImage
    private func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        // For simplicity, use a fixed size
        let targetSize = CGSize(width: 100, height: 100)
        
        // Set the size of the controller's view
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        // Render the view to UIImage
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}

extension AnyTransition {
    static var trailingBottom: AnyTransition {
        AnyTransition.asymmetric(insertion: .identity, removal: AnyTransition.move(edge: .trailing).combined(with: .move(edge: .bottom)))
    }
    
    static var leadingBottom: AnyTransition {
        AnyTransition.asymmetric(insertion: .identity, removal: AnyTransition.move(edge: .leading).combined(with: .move(edge: .bottom)))
    }
    
    static var middleBottom: AnyTransition {
        AnyTransition.asymmetric(insertion: .identity, removal: AnyTransition.move(edge: .bottom).combined(with: .move(edge: .bottom)))
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
