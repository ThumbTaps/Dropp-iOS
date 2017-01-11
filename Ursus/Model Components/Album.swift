//
//  Album.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/25/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class Album: NSObject, NSCoding {
	
	var itunesID: Int!
	var title: String!
	var releaseDate: Date!
	var summary: String?
	var genre: String?
	var itunesURL: URL!
	var artworkURL: URL?
	var seenByUser: Bool = false
	
	
	init(itunesID: Int!, title: String!, releaseDate: Date!, summary: String?, genre: String?, itunesURL: URL!, artworkURL: URL?) {
		
		super.init()
		
		self.itunesID = itunesID
		self.title = title
		self.releaseDate = releaseDate
		self.summary = summary
		self.genre = genre
		self.itunesURL = itunesURL
		self.artworkURL = artworkURL
	}
	
	
	// MARK: - NSCoding
	func encode(with aCoder: NSCoder) {
		
		aCoder.encode(self.itunesID, forKey: "itunesID")
		aCoder.encode(self.title, forKey: "title")
		aCoder.encode(self.releaseDate, forKey: "releaseDate")
		if self.summary != nil {
			aCoder.encode(self.summary, forKey: "summary")
		}
		if self.genre != nil {
			aCoder.encode(self.genre, forKey: "genre")
		}
		aCoder.encode(self.itunesURL, forKey: "itunesURL")
		if self.artworkURL != nil {
			aCoder.encode(self.artworkURL, forKey: "artworkURL")
		}
		aCoder.encode(self.seenByUser, forKey: "seenByUser")
	}
	required init?(coder aDecoder: NSCoder) {
		
		self.itunesID = aDecoder.decodeObject(forKey: "itunesID") as! Int
		self.title = aDecoder.decodeObject(forKey: "title") as! String
		self.releaseDate = aDecoder.decodeObject(forKey: "releaseDate") as! Date
		self.summary = aDecoder.decodeObject(forKey: "summary") as? String
		self.genre = aDecoder.decodeObject(forKey: "genre") as? String
		self.itunesURL = aDecoder.decodeObject(forKey: "itunesURL") as! URL
		self.artworkURL = aDecoder.decodeObject(forKey: "artworkURL") as? URL
		self.seenByUser = aDecoder.decodeBool(forKey: "seenByUser")
	}
	
	
	// MARK: - Custom Methods
	func isNewerThan(album: Album) -> Bool {
		return album.releaseDate > self.releaseDate
	}

}