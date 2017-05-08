//
//  NewReleasesViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson on 11/12/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class NewReleasesViewController: DroppViewController {
	
	@IBOutlet weak var releaseSortingButton: SortButton!
	@IBOutlet weak var newReleasesCountIndicator: UIButton!
	@IBOutlet weak var searchButton: SearchButton!
	@IBOutlet weak var artistsButton: ArtistsButton!
	@IBOutlet weak var settingsButton: SettingsButton!
	
	@IBOutlet weak var nowPlayingArtistQuickViewButton: NowPlayingArtistQuickViewButton!
	
	var newReleasesArtworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.newReleases.count)
	var previousReleasesArtworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.previousReleases.count)
	
	override var shouldShowFooter: Bool {
		return self.shouldShowNowPlayingArtist
	}
	override var indicator: UIView? {
		return ReleasesButton()
	}
	
	var shouldShowNowPlayingArtist: Bool {
		return PreferenceManager.shared.nowPlayingArtist != nil && !(PreferenceManager.shared.nowPlayingArtist?.isBeingFollowed ?? true)
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.collectionView?.refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 130, width: 45, height: 45))
		
		DispatchQueue.main.async {
			
			self.newReleasesCountIndicator.transform = CGAffineTransform(translationX: 0, y: 40)
			self.newReleasesCountIndicator.isHidden = true
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.nowPlayingArtistDidChange()
		
		PreferenceManager.shared.updateNewReleases()
		
		// start monitoring now playing artist changes
		PreferenceManager.shared.nowPlayingArtistDidChangeNotification.add(self, selector: #selector(self.nowPlayingArtistDidChange))
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		PreferenceManager.shared.nowPlayingArtistDidChangeNotification.remove(self)
	}
	
	override func willMove(toParentViewController parent: UIViewController?) {
		
		PreferenceManager.shared.newReleases.forEach({
			$0.thumbnailImage = nil
			$0.artworkImage = nil
		})
		
		PreferenceManager.shared.previousReleases.forEach({
			$0.thumbnailImage = nil
			$0.artworkImage = nil
		})
		
		super.willMove(toParentViewController: parent)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		
		print("There was a memory warning.")
	}
	
	
	
	
	// MARK: Methods
	@IBAction func showReleaseSortingOptions() {
		let alertController = UIAlertController(title: "Release Sorting", message: "Set sorting for new and previous releases", preferredStyle: .actionSheet)
		alertController.view.tintColor = ThemeKit.tintColor
		
		alertController.addAction(UIAlertAction(title: "Release Date", style: .default, handler: { (alertAction) in
			self.releaseSortingButton.setTitle(alertAction.title, for: .normal)
			PreferenceManager.shared.releaseSorting = .releaseDate
		}))
		alertController.addAction(UIAlertAction(title: "Release Title", style: .default, handler: { (alertAction) in
			self.releaseSortingButton.setTitle(alertAction.title, for: .normal)
			PreferenceManager.shared.releaseSorting = .releaseTitle
		}))
		alertController.addAction(UIAlertAction(title: "Artist Name", style: .default, handler: { (alertAction) in
			self.releaseSortingButton.setTitle(alertAction.title, for: .normal)
			PreferenceManager.shared.releaseSorting = .artistName
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	
	
	
	// MARK: - Notifications
	override func adjustToTheme() {
		super.adjustToTheme()
		
		self.nowPlayingArtistQuickViewButton.artistNameLabel.textColor = ThemeKit.primaryTextColor
		self.nowPlayingArtistQuickViewButton.secondaryLabel.textColor = ThemeKit.secondaryTextColor
	}
	override func didUpdateReleases() {
		
		self.collectionView?.prefetchDataSource = self
		self.collectionView?.dataSource = self
		self.collectionView?.delegate = self
		
		self.newReleasesArtworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.newReleases.count)
		self.previousReleasesArtworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.previousReleases.count)
		
		DispatchQueue.main.async {
			
			// adjust new releases count indicator
			self.newReleasesCountIndicator.setTitle("\(String(PreferenceManager.shared.newReleases.count)) New", for: .normal)
			if !PreferenceManager.shared.newReleases.isEmpty {
				if !(self.collectionView?.refreshControl?.isRefreshing ?? false) {
					
					self.newReleasesCountIndicator.isHidden = false
					UIViewPropertyAnimator(duration: ANIMATION_SPEED_MODIFIER * 0.6, dampingRatio: 0.6, animations: {
						self.newReleasesCountIndicator.transform = CGAffineTransform(translationX: 0, y: 0)
					}).startAnimation()
				}
			} else {
				UIViewPropertyAnimator(duration: ANIMATION_SPEED_MODIFIER * 0.3, curve: .easeOut, animations: {
					self.newReleasesCountIndicator.transform = CGAffineTransform(translationX: 0, y: 40)
				}).startAnimation()
			}
			
			self.collectionView?.performBatchUpdates({
				
				if !PreferenceManager.shared.newReleases.isEmpty {
					self.collectionView?.reloadSections([0])
				}
				
				if !PreferenceManager.shared.previousReleases.isEmpty {
					self.collectionView?.reloadSections([1])
				}
			})
			
			
			self.collectionView?.refreshControl?.endRefreshing()
			
		}
	}
	func nowPlayingArtistDidChange() {
		
		DispatchQueue.main.async {
			
			// if there is an artist to show quick view for AND	the artist is not already being followed
			if self.shouldShowNowPlayingArtist {
				
				self.nowPlayingArtistQuickViewButton.artistArtworkView.imageView.image = PreferenceManager.shared.nowPlayingArtist?.thumbnailImage
				self.nowPlayingArtistQuickViewButton.artistArtworkView.showArtwork(false)
				self.nowPlayingArtistQuickViewButton.artistNameLabel.text = PreferenceManager.shared.nowPlayingArtist?.name
				
				self.navController?.showFooter(true)
			} else {
				
				self.navController?.hideFooter(true)
			}
		}
	}
	
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Pass the selected object to the new view controller.
		
		if segue.identifier == "showRelease" {
			// set current release for release view controller
			var source = PreferenceManager.shared.newReleases
			switch self.collectionView?.indexPathsForSelectedItems?[0].section ?? 0 {
			case 0:
				source = PreferenceManager.shared.newReleases
				break
				
			case 1:
				source = PreferenceManager.shared.previousReleases
				break
				
			default: source = PreferenceManager.shared.newReleases
			}
			
			(segue.destination as? ReleaseViewController)?.currentRelease = source[(self.collectionView?.indexPathsForSelectedItems?[0].row)!]
			
		}
			
			
			
		else if segue.identifier == "showArtist" {
			(segue.destination as? ArtistViewController)?.currentArtist = PreferenceManager.shared.nowPlayingArtist
		}
		
		super.prepare(for: segue, sender: sender)
	}
}

extension NewReleasesViewController: UICollectionViewDataSourcePrefetching, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: UICollectionViewDataSourcePrefetching
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
		indexPaths.forEach { (indexPath) in
			
			var source = PreferenceManager.shared.newReleases
			
			if indexPath.section == 1 {
				
				source = PreferenceManager.shared.previousReleases
			}
			
			let artworkTask = source[indexPath.row].loadArtwork(thumbnailOnly: true) {
				
				switch indexPath.section {
				case 0:
					PreferenceManager.shared.newReleases[indexPath.row].thumbnailImage = source[indexPath.row].thumbnailImage
					break
				case 1:
					PreferenceManager.shared.previousReleases[indexPath.row].thumbnailImage = source[indexPath.row].thumbnailImage
					break
				default: break
				}
			}
			
			switch indexPath.section {
			case 0:
				self.newReleasesArtworkDownloadTasks[indexPath.row] = artworkTask
				break
			case 1:
				self.previousReleasesArtworkDownloadTasks[indexPath.row] = artworkTask
				break
			default: break
			}
		}
	}
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		
		indexPaths.forEach { (indexPath) in
			
			if indexPath.section == 0 {
				self.newReleasesArtworkDownloadTasks[indexPath.row]?.cancel()
			} else {
				self.previousReleasesArtworkDownloadTasks[indexPath.row]?.cancel()
			}
			
		}
	}
	
	
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		var numItems = PreferenceManager.shared.newReleases.count
		
		if section == 1 {
			
			numItems = PreferenceManager.shared.previousReleases.count
		}
		
		return numItems
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ReleasesCollectionViewHeader", for: indexPath) as? HeaderCollectionReusableView else {
			return UICollectionReusableView()
		}
		
		var timeUnit = " MONTHS"
		if PreferenceManager.shared.maxPreviousReleaseAge == 1 {
			timeUnit = "MONTH"
		}
		reusableView.textLabel.text = "IN THE PAST \(PreferenceManager.shared.maxPreviousReleaseAge == 1 ? "" : String(PreferenceManager.shared.maxPreviousReleaseAge))\(timeUnit)"
		
		reusableView.backgroundColor = ThemeKit.backdropOverlayColor
		reusableView.textLabel.textColor = ThemeKit.primaryTextColor
		
		return reusableView
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseCell", for: indexPath) as? ReleaseCollectionViewCell else {
			return UICollectionViewCell()
		}
		
		var source = PreferenceManager.shared.newReleases
		
		if indexPath.section == 1 {
			
			source = PreferenceManager.shared.previousReleases
		}
		
		let release = source[indexPath.row]
		
		DispatchQueue.main.async {
			
			cell.releaseTitleLabel.text = release.title
			cell.secondaryLabel.text = release.artist?.name
			
			cell.releaseArtworkView.hideArtwork()
			cell.releaseArtworkView.backgroundColor = ThemeKit.backgroundColor
			cell.backgroundColor = ThemeKit.backdropOverlayColor
			cell.releaseTitleLabel.textColor = ThemeKit.primaryTextColor
			cell.secondaryLabel.textColor = ThemeKit.secondaryTextColor
		}
		
		_ = source[indexPath.row].loadArtwork(thumbnailOnly: true) {

			DispatchQueue.main.async {
				cell.releaseArtworkView.imageView.image = source[indexPath.row].thumbnailImage
				if cell.releaseArtworkView.imageView.image != nil {
					cell.releaseArtworkView.showArtwork(true)
				}
			}
		}
		
		return cell
	}
	
	
	
	// MARK: - UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		
		var source = PreferenceManager.shared.newReleases
		if indexPath.section == 1 {
			source = PreferenceManager.shared.previousReleases
		}
		
		_ = source[indexPath.row].loadTracks()
		_ = source[indexPath.row].loadArtwork(thumbnailOnly: true)
	}
	
	
	
	
	// MARK: - UICollectionViewDelegateFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		if section == 0 {
			return .zero
		}
		if section == 1 && PreferenceManager.shared.previousReleases.isEmpty {
			return .zero
		}
		return CGSize(width: collectionView.frame.width, height: 50)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: collectionView.frame.size.width, height: 100)
	}
	
	
	
	// MARK: - UIScrollViewDelegate
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if scrollView == self.collectionView {
			if scrollView.contentOffset.y + scrollView.contentInset.top < 0 && !(self.collectionView?.refreshControl?.isRefreshing ?? false) {
				self.newReleasesCountIndicator.transform = CGAffineTransform(translationX: 0, y: -(scrollView.contentOffset.y + scrollView.contentInset.top))
			}
		}
	}
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		
		if scrollView == self.collectionView {
			if self.collectionView?.refreshControl?.isRefreshing ?? false {
				
				let deadlineTime = DispatchTime.now() + .milliseconds(300)
				DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
					PreferenceManager.shared.updateNewReleases(force: true)
					//if PreferenceManager.shared.lastReleasesUpdate != nil && PreferenceManager.shared.lastReleasesUpdate! < Calendar.current.date(byAdding: .minute, value: -5, to: Date())! {
					//} else {
					//	self.collectionView?.refreshControl?.endRefreshing()
					//}
					
				}
			}
		}
	}
}
