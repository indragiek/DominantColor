//
//  ColorDifference.swift
//  DominantColor
//
//  Created by Indragie on 12/22/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

private func degToRad(deg: Float) -> Float {
    return deg * Float(M_PI) / 180
}

private func radToDeg(rad: Float) -> Float {
    return rad * 180 / Float(M_PI)
}

// From http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE2000.html
//
// NOTE: This returns the *squared* color difference to save a sqrt() call because
// we don't care about the absolute metric. To get the actual value of the CIE 2000
// delta E, the output from this function must be square rooted.
public func CIE2000SquaredColorDifference(lab1: INVector3, lab2: INVector3, kL: Float = 1, kC: Float = 1, kH: Float = 1) -> Float {
    let (L1, a1, b1) = (lab1.x, lab1.y, lab1.z)
    let (L2, a2, b2) = (lab2.x, lab2.y, lab2.z)
    
    let ΔLp = L2 - L1
    let Lbp = (L1 + L2) / 2
    
    let C: (Float, Float) -> Float = { a, b in
        return sqrt(pow(a, 2) + pow(b, 2))
    }
    let (C1, C2) = (C(a1, b1), C(a2, b2))
    let Cb = (C1 + C2) / 2
    
    let G = (1 - sqrt(pow(Cb, 7) / (pow(Cb, 7) + pow(25, 7)))) / 2
    let ap: Float -> Float = { a in
        return a * (1 + G)
    }
    let (a1p, a2p) = (ap(a1), ap(a2))

    let (C1p, C2p) = (C(a1p, b1), C(a2p, b2))
    let ΔCp = C2p - C1p
    let Cbp = (C1p + C2p) / 2
    
    let hp: (Float, Float) -> Float = { ap, b in
        if ap == 0 && b == 0 { return 0 }
        let θ = radToDeg(atan(b / ap))
        return θ < 0 ? (θ + 360) : θ
    }
    let (h1p, h2p) = (hp(a1p, b1), hp(a2p, b2))
    let Δhabs = abs(h1p - h2p)
    let Δhp: Float = {
        if (C1p == 0 || C2p == 0) {
            return 0
        } else if Δhabs <= 180 {
            return h2p - h1p
        } else if h2p <= h1p {
            return h2p - h1p + 360
        } else {
            return h2p - h1p - 360
        }
    }()
    
    let ΔHp = 2 * sqrt(C1p * C2p) * sin(degToRad(Δhp / 2))
    let Hbp: Float = {
        if (C1p == 0 || C2p == 0) {
            return h1p + h2p
        } else if Δhabs > 180 {
            return (h1p + h2p + 360) / 2
        } else {
            return (h1p + h2p) / 2
        }
    }()
    
    let T = 1
        - 0.17 * cos(degToRad(Hbp - 30))
        + 0.24 * cos(degToRad(2 * Hbp))
        + 0.32 * cos(degToRad(3 * Hbp + 6))
        - 0.20 * cos(degToRad(4 * Hbp - 63))
    
    let Sl = 1 + (0.015 * pow(Lbp - 50, 2)) / sqrt(20 + pow(Lbp - 50, 2))
    let Sc = 1 + 0.045 * Cbp
    let Sh = 1 + 0.015 * Cbp * T
    
    let Δθ = 30 * exp(-pow((Hbp - 275) / 25, 2))
    let Rc = 2 * sqrt(pow(Cbp, 7) / (pow(Cbp, 7) + pow(25, 7)))
    let Rt = -Rc * sin(degToRad(2 * Δθ))
    
    let Lterm = ΔLp / (kL * Sl)
    let Cterm = ΔCp / (kC * Sc)
    let Hterm = ΔHp / (kH * Sh)
    return pow(Lterm, 2) + pow(Cterm, 2) + pow(Hterm, 2) + Rt * Cterm * Hterm
}
