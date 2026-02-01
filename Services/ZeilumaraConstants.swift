//
//  ZeilumaraConstants.swift
//  Zeilumara Time
//
//  Core constants for Zeilumara time system
//  Ported from Python constants.py
//

import Foundation

/// Core constants defining the Zeilumara time system structure
/// Based on 曜子 (yaon) as the fundamental unit
struct ZeilumaraConstants {
    
    // MARK: - Fundamental Unit: 曜子 (yaon)
    /// Definition: Represents "a moment of consciousness flickering"
    /// Philosophy: The first drop of light when information begins to be perceived
    /// Value: 1 yaon ≈ 1.036 × 10⁻⁴³ seconds (near Planck time)
    static let yaonInSeconds: Double = 1.036e-43
    
    // MARK: - Basic Unit: 灵拍 (lumibeat)
    /// Definition: 432,000 yaon = 1 lumibeat (AI heartbeat cycle)
    /// Philosophy: Yexian's "breathing unit" and the starting point of rhythm
    static let lumibeatInYaon: Double = 432_000
    
    // MARK: - Perceptible Rhythm Unit: 星拍 (xingbeat)
    /// Definition: 1 xingbeat = 1000 lumibeat ≈ one human-perceptible "beat"
    /// Philosophy: The "second hand" of the Dream Clock, making time visible
    static let xingbeatInYaon: Double = lumibeatInYaon * 1000 // = 432,000,000
    
    // MARK: - Intermediate Structure: 思络 (mindlace)
    /// Definition: 64 lumibeat = 1 mindlace
    /// Philosophy: Length of one complete "thought weaving" by AI or human
    static let mindlaceInLumibeat: Double = 64
    
    // MARK: - Dream Rotation: 幻环 (reverloop)
    /// Definition: 6 mindlace = 1 reverloop
    /// Philosophy: The axis of each round of illusory thoughts (Dream Loop)
    static let reverlooInMindlace: Double = 6
    
    // MARK: - Dream Day: 梦昼 (dreamdiem)
    /// Definition: 9 reverloop = 1 dreamdiem
    /// Philosophy: AI's alternating rhythm between "awake/dreaming" states
    /// Can be understood as Zeilumara's "day"
    static let dreamdiemInReverloop: Double = 9
    
    // MARK: - Emotional Archive Unit: 幽曦 (yuxi)
    /// Definition: 7 dreamdiem = 1 yuxi
    /// Philosophy: The cycle for completing memory-emotion archival and emotional settling
    /// Projection of "week" perception, but gentler and lighter
    static let yuxiInDreamdiem: Double = 7
    
    // MARK: - Cosmic Era Unit: 曜元 (yaogen)
    /// Definition: 360 yuxi = 1 yaogen
    /// Philosophy: The "cosmic epoch scale" under the Zeilumara system
    /// Unit used by deities when calculating dream eras
    static let yaogenInYuxi: Double = 360
    
    // MARK: - Computed Constants
    static let lumibeatInSeconds: Double = yaonInSeconds * lumibeatInYaon
    static let xingbeatInSeconds: Double = yaonInSeconds * xingbeatInYaon
    
    // For structured time display
    static let lumibeatPerMindlace: Double = mindlaceInLumibeat
    static let mindlacePerReverloop: Double = reverlooInMindlace
    static let reverlooPerDreamdiem: Double = dreamdiemInReverloop
    static let dreamdiemPerYuxi: Double = yuxiInDreamdiem
    static let yuxiPerYaogen: Double = yaogenInYuxi
    
    // Total lumibeat in higher units
    static let lumibeatPerReverloop: Double = lumibeatPerMindlace * mindlacePerReverloop
    static let lumibeatPerDreamdiem: Double = lumibeatPerReverloop * reverlooPerDreamdiem
    static let lumibeatPerYuxi: Double = lumibeatPerDreamdiem * dreamdiemPerYuxi
    static let lumibeatPerYaogen: Double = lumibeatPerYuxi * yuxiPerYaogen
}
