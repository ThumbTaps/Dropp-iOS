//
//  UrsusStoryboardSegue.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/1/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class UrsusStoryboardSegue: UIStoryboardSegue {
    
    override func perform() {
		
		if self.identifier == "NewAlbums->Settings" {
			self.source.present(self.destination, animated: false)
			
		} else if self.identifier == "Settings->NewAlbums" {
			self.source.dismiss(animated: false)
		}
		
			
			
			
		else if self.identifier == "NewAlbums->FollowingArtists" {
			self.source.present(self.destination, animated: false)
			
		} else if self.identifier == "FollowingArtists->NewAlbums" {
			self.source.dismiss(animated: false)
		}
			
			
			
			
			
        else if self.identifier == "NewAlbums->ArtistSearch" {
            self.source.present(self.destination, animated: false)
			
		} else if self.identifier == "ArtistSearch->NewAlbums" {
			
			let artistSearch = self.source as! ArtistSearchViewController
			
			artistSearch.searchBar.textField.text = ""
			
			DispatchQueue.main.async {
				
				artistSearch.searchBar.textField.resignFirstResponder()
				
				artistSearch.view.removeConstraint(artistSearch.searchBarCenteredConstraint)
				artistSearch.view.addConstraint(artistSearch.searchBarHidingConstraint)
				
				UIView.animate(withDuration: 0.85, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .curveEaseIn, animations: {
					
					artistSearch.view.layoutIfNeeded()
				}, completion: { (Bool) in
					
					artistSearch.dismiss(animated: false)
				})
				
				UIView.animate(withDuration: 0.4, animations: {
					artistSearch.blurView.effect = nil
				})
			}
		}
			
			
			
			
            
            
            
            
            
			
        else if self.identifier == "ArtistSearch->ArtistSearchResults" {
            self.source.present(self.destination, animated: false)

        } else if self.identifier == "ArtistSearchResults->ArtistSearch" {
            self.source.dismiss(animated: false)
        }
        
        
        
        
        else if self.identifier == "ArtistSearch->Artist" {
            self.source.present(self.destination, animated: false)
            
        } else if self.identifier == "Artist->ArtistSearch" {
            self.source.dismiss(animated: false)
        }
    }
	
}