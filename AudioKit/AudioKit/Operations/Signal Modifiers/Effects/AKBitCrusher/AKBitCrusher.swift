//
//  AKBitCrusher.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/** This will digitally degrade a signal. */
public class AKBitCrusher: AKOperation {

    // MARK: - Properties

    private var internalAU: AKBitCrusherAudioUnit?
    private var token: AUParameterObserverToken?

    private var bitDepthParameter: AUParameter?
    private var sampleRateParameter: AUParameter?

    /** The bit depth of signal output. Typically in range (1-24). Non-integer values are OK. */
    public var bitDepth: Float = 8 {
        didSet {
            bitDepthParameter?.setValue(bitDepth, originator: token!)
        }
    }
    /** The sample rate of signal output. */
    public var sampleRate: Float = 10000 {
        didSet {
            sampleRateParameter?.setValue(sampleRate, originator: token!)
        }
    }

    // MARK: - Initializers

    /** Initialize this bitcrusher operation */
    public init(
        _ input: AKOperation,
        bitDepth: Float = 8,
        sampleRate: Float = 10000) {

        self.bitDepth = bitDepth
        self.sampleRate = sampleRate
        super.init()

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x62746372 /*'btcr'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKBitCrusherAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKBitCrusher",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKBitCrusherAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: nil)
        }

        guard let tree = internalAU?.parameterTree else { return }

        bitDepthParameter   = tree.valueForKey("bitDepth")   as? AUParameter
        sampleRateParameter = tree.valueForKey("sampleRate") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.bitDepthParameter!.address {
                    self.bitDepth = value
                } else if address == self.sampleRateParameter!.address {
                    self.sampleRate = value
                }
            }
        }

    }
}
