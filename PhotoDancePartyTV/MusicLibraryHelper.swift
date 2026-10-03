//
//  MusicLibraryHelper.swift
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

import Foundation

#if canImport(MusicKit)
import MusicKit
#endif

@objc class MusicLibraryHelper: NSObject {

    /// Returns true if MusicKit library requests are available (tvOS 16+)
    @objc static func isLibraryAvailable() -> Bool {
        if #available(tvOS 16.0, *) {
            return true
        }
        return false
    }

    /// Requests MusicKit authorization. Calls completion with true if authorized.
    @objc static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        #if canImport(MusicKit)
        if #available(tvOS 15.0, *) {
            Task {
                let status = await MusicAuthorization.request()
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        } else {
            completion(false)
        }
        #else
        completion(false)
        #endif
    }

    /// Fetches songs from the user's Apple Music library.
    /// Returns NSArray of NSDictionary with keys: trackName, artistName, artworkUrl100, storeID, isUserLibrary.
    /// Returns nil on tvOS < 16 or error.
    @objc static func fetchLibrarySongs(completion: @escaping (NSArray?) -> Void) {
        #if canImport(MusicKit)
        if #available(tvOS 16.0, *) {
            Task {
                do {
                    var libraryRequest = MusicLibraryRequest<Song>()
                    libraryRequest.limit = 100
                    libraryRequest.sort(by: \.title, ascending: true)

                    let libraryResponse = try await libraryRequest.response()
                    let songsArray = NSMutableArray()

                    for song in libraryResponse.items {
                        let songDict = NSMutableDictionary()
                        songDict["trackName"] = song.title
                        songDict["artistName"] = song.artistName
                        songDict["isUserLibrary"] = true
                        songDict["storeID"] = "\(song.id.rawValue)"

                        if let artworkURL = song.artwork?.url(width: 100, height: 100) {
                            songDict["artworkUrl100"] = artworkURL.absoluteString
                        }

                        songsArray.add(songDict)
                    }

                    // Convert to Swift Array (Sendable) before capturing in closure
                    let resultArray = (songsArray.copy() as? [Any]) ?? []
                    DispatchQueue.main.async {
                        completion(resultArray as NSArray)
                    }
                } catch {
                    NSLog("MusicLibraryHelper: Failed to fetch library songs: %@", error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
        }
        #else
        completion(nil)
        #endif
    }

    /// Plays a song from the user's library by its MusicKit ID.
    /// Uses ApplicationMusicPlayer which is the correct way to play MusicKit library songs.
    @objc static func playSong(withID songID: String, completion: @escaping (Bool) -> Void) {
        #if canImport(MusicKit)
        if #available(tvOS 16.0, *) {
            Task {
                do {
                    // Fetch the song from the library by ID
                    var libraryRequest = MusicLibraryRequest<Song>()
                    libraryRequest.filter(matching: \.id, equalTo: MusicItemID(songID))
                    let libraryResponse = try await libraryRequest.response()

                    guard let song = libraryResponse.items.first else {
                        NSLog("MusicLibraryHelper: Song not found for ID: %@", songID)
                        DispatchQueue.main.async { completion(false) }
                        return
                    }

                    let musicPlayer = ApplicationMusicPlayer.shared
                    musicPlayer.queue = [song]
                    musicPlayer.state.repeatMode = .all
                    try await musicPlayer.play()

                    DispatchQueue.main.async { completion(true) }
                } catch {
                    NSLog("MusicLibraryHelper: Failed to play song: %@", error.localizedDescription)
                    DispatchQueue.main.async { completion(false) }
                }
            }
        } else {
            completion(false)
        }
        #else
        completion(false)
        #endif
    }

    /// Stops MusicKit ApplicationMusicPlayer playback.
    @objc static func stopPlayback() {
        #if canImport(MusicKit)
        if #available(tvOS 15.0, *) {
            ApplicationMusicPlayer.shared.stop()
        }
        #endif
    }
}
