//
//  ReleaseArtView.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/26/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ReleaseArtView: UIView {
	
	@IBInspectable var themed: Bool = true
	@IBOutlet weak var imageView: ReleaseArtViewImageView!

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		if self.themed {
			
			self.themeDidChange()
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		if self.themed {
			
			self.themeDidChange()
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
	}
	func themeDidChange() {
		self.setNeedsDisplay()
		
	}

	override func draw(_ rect: CGRect) {
		
		if PreferenceManager.shared.theme == .dark {
			StyleKit.drawDarkPlaceholderReleaseArtwork(frame: rect, resizing: .aspectFit)
			self.layer.borderColor = StyleKit.darkStrokeColor.cgColor
		} else {
			StyleKit.drawLightPlaceholderReleaseArtwork(frame: rect, resizing: .aspectFit)
			self.layer.borderColor = StyleKit.lightStrokeColor.cgColor
		}
		
		self.layer.backgroundColor = UIColor.clear.cgColor
		self.layer.borderWidth = min(rect.width / 70, 3)
		self.layer.cornerRadius = rect.width / 24
		self.layer.masksToBounds = true
	}
	
	
	func showArtwork() {
		
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.85, options: .curveEaseOut, animations: {
			self.imageView.alpha = 1
			self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
		})
		
	}
}


@IBDesignable
class ReleaseArtViewImageView: UIImageView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}
	func commonInit() {
		
		self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
		self.alpha = 0
	}
}
