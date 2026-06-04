//
//  modelDatabase.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

import SwiftData
import Foundation

@Model
class User {
    var name: String = ""
    var profileImage: Data? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \Room.createdBy)
    var rooms: [Room]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Photo.user)
    var photos: [Photo]? = []
    
    init(name: String, profileImage: Data? = nil) {
        self.name = name
        self.profileImage = profileImage
    }
    //wed
    @Relationship(deleteRule: .cascade)
    var participations: [RoomParticipant]? = []
}

@Model
class Room {
    var name: String = ""
    var code: String = ""
    var category: String = ""
    var location: String = ""
    var maxPhotos: Int = 0
    var isClosed: Bool = false
    var createdBy: User? = nil
    
    // wed
      var missionTitle: String = ""
      var missionDescription: String = ""
    var isStarted: Bool = false //for not host
    
    @Relationship(deleteRule: .cascade, inverse: \Photo.room)
    var photos: [Photo]? = []
    
    init(name: String, code: String, category: String, location: String, maxPhotos: Int) {
        self.name = name
        self.code = code
        self.category = category
        self.location = location
        self.maxPhotos = maxPhotos
        self.isClosed = false
    }
   //wed
    @Relationship(deleteRule: .cascade)
    var participants: [RoomParticipant]? = []
}

@Model
class Photo {
    var url: String = ""
    var uploadedAt: Date = Date()
    var room: Room? = nil
    var user: User? = nil
    
    init(url: String, room: Room, user: User) {
        self.url = url
        self.uploadedAt = Date()
        self.room = room
        self.user = user
    }
}
//wed
@Model
class RoomParticipant {

    var joinedAt: Date = Date()

    @Relationship(inverse: \User.participations)
    var user: User?

    @Relationship(inverse: \Room.participants)
    var room: Room?

    init(user: User, room: Room) {
        self.user = user
        self.room = room
    }
}
