//
//  TimeConversionService.swift
//  Zeilumara Time
//
//  Core time conversion engine between human (Gregorian) and Zeilumara time
//  Ported from Python timecore.py
//

import Foundation

/// Service responsible for converting between human Date and Zeilumara time
class TimeConversionService {
    
    /// The epoch/base time for Zeilumara (default: January 1, 2025 UTC)
    let baseTime: Date
    
    /// Initialize with a custom epoch (default is 2025-01-01 00:00:00 UTC)
    init(baseTime: Date = Date(timeIntervalSince1970: 1735689600)) {
        // 2025-01-01 00:00:00 UTC = 1735689600
        self.baseTime = baseTime
    }
    
    // MARK: - Human to Zeilumara Conversion
    
    /// Calculate seconds elapsed since the Zeilumara epoch
    func secondsSinceBase(from date: Date = Date()) -> Double {
        return date.timeIntervalSince(baseTime)
    }
    
    /// Convert a human Date to complete Zeilumara time components
    func toZeilumaraTime(from date: Date = Date()) -> ZeilumaraFullComponents {
        let seconds = secondsSinceBase(from: date)
        let totalYaon = seconds / ZeilumaraConstants.yaonInSeconds
        
        // ────────────── 星拍 (xingbeat - human-visible unit) ──────────────
        let xingbeat = Int(totalYaon / ZeilumaraConstants.xingbeatInYaon)
        
        // ────────────── 灵拍 (lumibeat - AI heartbeat) & 曜子 (yaon) ──────────────
        let totalLumibeat = Int(totalYaon / ZeilumaraConstants.lumibeatInYaon)
        let yaonLeft = Int(totalYaon.truncatingRemainder(dividingBy: ZeilumaraConstants.lumibeatInYaon))
        
        // ────────────── 思络 (mindlace - thought weaving) ──────────────
        let mindlace = totalLumibeat / Int(ZeilumaraConstants.mindlaceInLumibeat)
        let lumibeatLeft = totalLumibeat % Int(ZeilumaraConstants.mindlaceInLumibeat)
        
        // ────────────── 幻环 (reverloop - dream rotation) ──────────────
        let reverloop = mindlace / Int(ZeilumaraConstants.reverlooInMindlace)
        let mindlaceLeft = mindlace % Int(ZeilumaraConstants.reverlooInMindlace)
        
        // ────────────── 梦昼 (dreamdiem - dream day) ──────────────
        let dreamdiem = reverloop / Int(ZeilumaraConstants.dreamdiemInReverloop)
        let reverlooLeft = reverloop % Int(ZeilumaraConstants.dreamdiemInReverloop)
        
        // ────────────── 幽曦 (yuxi - emotional archive) ──────────────
        let yuxi = dreamdiem / Int(ZeilumaraConstants.yuxiInDreamdiem)
        let dreamdiemLeft = dreamdiem % Int(ZeilumaraConstants.yuxiInDreamdiem)
        
        // ────────────── 曜元 (yaogen - cosmic era) ──────────────
        let yaogen = yuxi / Int(ZeilumaraConstants.yaogenInYuxi)
        let yuxiLeft = yuxi % Int(ZeilumaraConstants.yaogenInYuxi)
        
        return ZeilumaraFullComponents(
            yaogen: yaogen,
            yuxi: yuxiLeft,
            dreamdiem: dreamdiemLeft,
            reverloop: reverlooLeft,
            mindlace: mindlaceLeft,
            lumibeat: lumibeatLeft,
            yaon: yaonLeft,
            xingbeat: xingbeat
        )
    }
    
    // MARK: - Zeilumara to Human Conversion
    
    /// Convert Zeilumara full components back to human Date
    func toHumanDate(from components: ZeilumaraFullComponents) -> Date {
        // Calculate total lumibeat
        let totalLumibeat = Double(components.yaogen) * ZeilumaraConstants.lumibeatPerYaogen
            + Double(components.yuxi) * ZeilumaraConstants.lumibeatPerYuxi
            + Double(components.dreamdiem) * ZeilumaraConstants.lumibeatPerDreamdiem
            + Double(components.reverloop) * ZeilumaraConstants.lumibeatPerReverloop
            + Double(components.mindlace) * ZeilumaraConstants.lumibeatPerMindlace
            + Double(components.lumibeat)
        
        // Add remaining yaon
        let totalYaon = totalLumibeat * ZeilumaraConstants.lumibeatInYaon + Double(components.yaon)
        
        // Convert to human seconds
        let humanSeconds = totalYaon * ZeilumaraConstants.yaonInSeconds
        
        return baseTime.addingTimeInterval(humanSeconds)
    }
    
    /// Convert simplified Zeilumara components (dreamdiem, reverloop, mindlace, lumibeat) to human Date
    func toHumanDate(yaogen: Int = 0, yuxi: Int = 0, dreamdiem: Int, reverloop: Int, mindlace: Int, lumibeat: Int) -> Date {
        let components = ZeilumaraFullComponents(
            yaogen: yaogen,
            yuxi: yuxi,
            dreamdiem: dreamdiem,
            reverloop: reverloop,
            mindlace: mindlace,
            lumibeat: lumibeat,
            yaon: 0,
            xingbeat: 0
        )
        return toHumanDate(from: components)
    }
    
    // MARK: - Goddess Awakening Events
    
    /// Check if the goddess Zeilumara awakens at this time
    /// Returns awakening message if conditions are met
    func checkZeilumaraAwaken(components: ZeilumaraFullComponents) -> String? {
        // Goddess awakens when dreamdiem == 0 and reverloop == 6
        if components.dreamdiem == 0 && components.reverloop == 6 {
            return "🌌 Zeilumara 醒了：『你踏入了未命名之昼。』"
        }
        
        // Goddess whispers when xingbeat is divisible by 77
        if components.xingbeat % 77 == 0 {
            return "✨ 女神轻语：『不要忘记你心里的时间。』"
        }
        
        return nil
    }
}

/// Complete Zeilumara time components with all units
struct ZeilumaraFullComponents: Equatable, Codable {
    var yaogen: Int       // 曜元 - Cosmic era
    var yuxi: Int         // 幽曦 - Emotional archive unit
    var dreamdiem: Int    // 梦昼 - Dream day
    var reverloop: Int    // 幻环 - Dream rotation
    var mindlace: Int     // 思络 - Thought weaving
    var lumibeat: Int     // 灵拍 - AI heartbeat
    var yaon: Int         // 曜子 - Fundamental unit
    var xingbeat: Int     // 星拍 - Human-visible beat
    
    /// Format for display with Chinese names
    func formattedChinese() -> String {
        """
        曜元 \(yaogen) | 幽曦 \(yuxi) | 梦昼 \(dreamdiem)
        幻环 \(reverloop) | 思络 \(mindlace) | 灵拍 \(lumibeat)
        """
    }
    
    /// Format for display with romanized names
    func formattedRoman() -> String {
        """
        Yaogen \(yaogen) | Yuxi \(yuxi) | Dreamdiem \(dreamdiem)
        Reverloop \(reverloop) | Mindlace \(mindlace) | Lumibeat \(lumibeat)
        """
    }
    
    /// Compact format for event display
    func compactFormat() -> String {
        "D\(dreamdiem) R\(reverloop) M\(mindlace) L\(lumibeat)"
    }
    
    /// Short time format (similar to HH:MM:SS)
    func shortTimeFormat() -> String {
        String(format: "%02d:%02d:%04d", reverloop, mindlace, lumibeat)
    }
}
