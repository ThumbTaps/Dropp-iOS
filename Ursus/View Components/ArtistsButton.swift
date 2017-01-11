//
//  ArtistsButton.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/3/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ArtistsButton: UrsusButton {
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		super.draw(rect)
		
		if PreferenceManager.shared.themeMode == .dark {
			StyleKit.drawArtistsIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.darkIconGlyphColor)
		} else {
			StyleKit.drawArtistsIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.lightIconGlyphColor)
		}
	}
	
}
