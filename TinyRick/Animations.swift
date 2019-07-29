//
//  Animations.swift
//  TinyRick
//
//  Created by Brandon Mahoney on 7/27/19.
//  Copyright © 2019 Brandon Mahoney. All rights reserved.
//

import Foundation


enum Dance: CaseIterable {
    case breakdanceEnding1
    case breakdanceEnding2
    case breakdanceEnding3
    
    var animationIdentifier: String {
        switch self {
        case .breakdanceEnding1: return "BreakdanceEnding1-1"
        case .breakdanceEnding2: return "BreakdanceEnding2-1"
        case .breakdanceEnding3: return "BreakdanceEnding3-1"
        }
    }
    
    var key: String {
        switch self {
        case .breakdanceEnding1: return "breakdanceEnding1"
        case .breakdanceEnding2: return "breakdanceEnding2"
        case .breakdanceEnding3: return "breakdanceEnding3"
        }
    }
    
    var sceneName: String {
        switch self {
        case .breakdanceEnding1: return "art.scnassets/TinyRick/BreakdanceEnding1"
        case .breakdanceEnding2: return "art.scnassets/TinyRick/BreakdanceEnding2"
        case .breakdanceEnding3: return "art.scnassets/TinyRick/BreakdanceEnding3"
        }
    }
}

enum FightMove: CaseIterable {
    case fightIdle
    case spinHookKick
    case jabCross
    case roundhouse
    
    
    var animationIdentifier: String {
        switch self {
            case .fightIdle: return "IdleFixed-1"
            case .spinHookKick: return "SpinHookKick-1"
            case .jabCross: return "JabCrossFixed-1"
            case .roundhouse: return "RoundhouseFixed-1"
        }
    }
    
    var key: String {
        switch self {
            case .fightIdle: return "fightIdle"
            case .spinHookKick: return "spinHookKick"
            case .jabCross: return "jabCross"
            case .roundhouse: return "roundhouse"
        }
    }
    
    var sceneName: String {
        switch self {
            case .fightIdle: return "art.scnassets/TinyRick/FightIdle"
            case .spinHookKick: return "art.scnassets/TinyRick/SpinHookKick"
            case .jabCross: return "art.scnassets/TinyRick/JabCross"
            case .roundhouse: return "art.scnassets/TinyRick/Roundhouse"
        }
    }
}



