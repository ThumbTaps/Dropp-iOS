//
//  DroppButton.swift
//  Dropp
//
//  Created by Jeffery Jackson on 11/13/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class DroppButton: UIButton {
	
	@IBInspectable var tapScale: CGFloat = 0.9 {
		didSet {
			self.setNeedsDisplay()
		}
	}
	@IBInspectable var badged: Bool = false {
		didSet {
			self.setNeedsDisplay()
		}
	}
	@IBInspectable var iconOnly: Bool = false {
		didSet {
			self.setNeedsDisplay()
		}
	}
	@IBInspectable var haptic: Bool = false
	
	var iconRect: CGRect!
	var resizingBehavior: StyleKit.ResizingBehavior = .aspectFit {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		self.setNeedsDisplay()
	}
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		self.layer.cornerRadius = 6
		self.layer.masksToBounds = true
		
		self.iconRect = CGRect(x: 0, y: 0, width: rect.height, height: rect.height)
		
		if self.badged {
			self.iconRect = CGRect(x: 2.5, y: 0, width: rect.height, height: rect.height)
			self.contentMode = .left
		}

		if self.iconOnly {
			self.layer.backgroundColor = UIColor.clear.cgColor
		} else {
			self.layer.backgroundColor = self.tintColor.cgColor

			if self.tintColor.isDarkColor {
				self.setTitleColor(StyleKit.darkGlyphColor, for: .normal)
			} else {
				self.setTitleColor(StyleKit.lightGlyphColor, for: .normal)
			}
		}
		
	}
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let marginForError: CGFloat = 10
		let relativeFrame = self.bounds
		let hitTestEdgeInsets = UIEdgeInsetsMake(-marginForError, -marginForError, -marginForError, -marginForError)
		let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
		return hitFrame.contains(point)
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		if self.haptic {
			let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
			feedbackGenerator.impactOccurred()
		}
		
		UIViewPropertyAnimator(duration: 0.4 * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.5) {
			self.transform = CGAffineTransform(scaleX: self.tapScale, y: self.tapScale)
		}.startAnimation()
		
	}
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		
		if let touchLocation = touches.first?.location(in: self) {
			
			if !self.point(inside: touchLocation, with: event) {
				self.touchesCancelled(touches, with: event)
			}
		}
		
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		UIViewPropertyAnimator(duration: 0.5 * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.5) {
			self.transform = CGAffineTransform(scaleX: 1, y: 1)
		}.startAnimation()
		
		super.touchesEnded(touches, with: event)
	}
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		self.touchesEnded(touches, with: event)
	}

}
