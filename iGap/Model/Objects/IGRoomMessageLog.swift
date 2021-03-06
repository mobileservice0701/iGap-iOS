//
//  IGMessageViewController.swift
/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

class IGRoomMessageLog: Object {
    enum LogType: Int {
        case userJoined = 0
        case userDeleted
        case roomCreated
        case memberAdded
        case memberKicked
        case memberLeft
        case roomConvertedToPublic
        case roomConvertedToPrivate
        case memberJoinedByInviteLink
        case roomDeleted
    }
    
    enum ExtraType: Int {
        case noExtra
        case targetUser
    }
    
    
    //properties
    dynamic var id:             String?
    dynamic var typeRaw:        LogType.RawValue    = LogType.userJoined.rawValue
    dynamic var extraTypeRaw:   ExtraType.RawValue  = ExtraType.noExtra.rawValue
    dynamic var targetUser:     IGRegisteredUser?
    //ignored properties
    var type: LogType {
        get {
            if let a = LogType(rawValue: typeRaw) {
                return a
            }
            return .userJoined
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
    var extraType: ExtraType {
        get {
            if let a = ExtraType(rawValue: extraTypeRaw){
                return a
            }
            return .noExtra
        }
        
        set {
            extraTypeRaw = newValue.rawValue
        }
    }
    
    
    
    //MARK: - Class methods
    class func textForLogMessage(_ message: IGRoomMessage) -> String {
        var actorUsernameTitle = ""
        
        if let actor = message.authorUser {
            actorUsernameTitle = actor.displayName
        } else {
            actorUsernameTitle = "Someone"
        }
        
        var bodyString = ""
        switch (message.log?.type)! {
        case .userJoined:
            bodyString = actorUsernameTitle + " joined iGap"
        case .userDeleted:
            bodyString = actorUsernameTitle + " deleted their account"
        case .roomCreated:
            if message.authorRoom != nil {
                bodyString = "Channel was created"
            } else {
                bodyString = actorUsernameTitle + " created this room"
            }
        case .memberAdded:
            bodyString = actorUsernameTitle + " added"
        case .memberKicked:
            bodyString = actorUsernameTitle + " kicked"
        case .memberLeft:
            bodyString = actorUsernameTitle + " left"
        case .roomConvertedToPublic:
            if message.authorRoom != nil {
                bodyString = "This channel is now public"
            } else {
                bodyString = actorUsernameTitle + " changed room to public"
            }
        case .roomConvertedToPrivate:
            if message.authorRoom != nil {
                bodyString = "This channel is now private"
            } else {
                bodyString = actorUsernameTitle + " changed room to private"
            }
        case .memberJoinedByInviteLink:
            bodyString = actorUsernameTitle + " joined via invite link"
        case .roomDeleted:
            bodyString = "This room was deleted"
        }
        
        if let target = message.log?.targetUser {
            bodyString =  bodyString + " " + target.displayName
        }
        
        return bodyString
    }
    
    //MARK: - Instance methods
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["type", "extraType"]
    }
    
    convenience init(igpRoomMessageLog: IGPRoomMessageLog, for message: IGRoomMessage) {
        self.init()
        self.id = message.primaryKeyId
        
        
        switch igpRoomMessageLog.igpType {
        case .userJoined:
            self.type = .userJoined
        case .userDeleted:
            self.type = .userDeleted
        case .roomCreated:
            self.type = .roomCreated
        case .memberAdded:
            self.type = .memberAdded
        case .memberKicked:
            self.type = .memberKicked
        case .memberLeft:
            self.type = .memberLeft
        case .roomConvertedToPublic:
            self.type = .roomConvertedToPublic
        case .roomConvertedToPrivate:
            self.type = .roomConvertedToPrivate
        case .memberJoinedByInviteLink:
            self.type = .memberJoinedByInviteLink
        case .roomDeleted:
            self.type = .roomDeleted
        }
        
        switch igpRoomMessageLog.igpExtraType {
        case .noExtra:
            self.extraType = .noExtra
        case .targetUser:
            self.extraType = .targetUser
        }
        
        if igpRoomMessageLog.hasIgpTargetUser {
            let predicate = NSPredicate(format: "id = %d", igpRoomMessageLog.igpTargetUser.igpId)
            let realm = try! Realm()
            if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
                self.targetUser = userInDb
            }
        }
    }
    
    //detach from current realm
    func detach() -> IGRoomMessageLog {
        let detachedRoomMessageLog = IGRoomMessageLog(value: self)
        if let user = self.targetUser {
            let detachedUser = user.detach()
            detachedRoomMessageLog.targetUser = detachedUser
        }
        return detachedRoomMessageLog
    }
    
}
