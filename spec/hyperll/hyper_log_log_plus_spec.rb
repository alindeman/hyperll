require 'base64'
require 'hyperll/hyper_log_log_plus'

module Hyperll
  describe HyperLogLogPlus do
    describe 'validations' do
      specify 'p must be greater than or equal to 4' do
        expect { HyperLogLogPlus.new(1) }.to raise_error(ArgumentError)
      end

      specify 'sp must be less than 32' do
        expect { HyperLogLogPlus.new(11, 32) }.to raise_error(ArgumentError)
      end

      specify 'p must be less than or equal to sp' do
        expect { HyperLogLogPlus.new(16, 11) }.to raise_error(ArgumentError)
      end
    end

    describe 'format' do
      it 'defaults to normal (non-sparse) format' do
        hllp = HyperLogLogPlus.new(11)
        expect(hllp.format).to eq(:normal)
      end

      it 'defaults to sparse format if sp is specified' do
        hllp = HyperLogLogPlus.new(11, 16)
        expect(hllp.format).to eq(:sparse)
      end
    end

    describe 'serialization' do
      it 'unserializes a normal format instance from a string' do
        # hllp = Java::com::clearspring::analytics::stream::cardinality::HyperLogLogPlus.new(4)
        # hllp.offer(1)
        # hllp.offer(2)
        # h.getBytes()
        serialized = [-1, -1, -1, -2, 4, 0, 0, 12, 2, 0, 0, 0, 0, 48, 0, 0, 0, 0, 0, 0].pack("C*")
        hllp = HyperLogLogPlus.unserialize(serialized)

        expect(hllp.format).to eq(:normal)
        expect(hllp.p).to eq(4)
        expect(hllp.sp).to eq(0)
        expect(hllp.cardinality).to eq(2)
      end

      it 'unserializes a sparse format instance from a string'
    end


    describe 'smoke tests' do
      it 'unserializes a normal format instance with cardinality ~2959' do
        hllp = HyperLogLogPlus.unserialize(Base64.decode64("
          /////gsQANgKAACMQQQAAAIEMYyCBACEIQAxiEQEFIwiAiAMIAIxgKgEMowkBhEEIABAB
          AIAMYwjBjEQIQgRiEMAEBBADEIIIQIgiCIAEYBDAkGAZwISjCUMEQgDBAGIAQoRhAEMEQ
          gCBDIUBABAAGAAIgQABCAEQAQxmIICQYQBCjIMQwgTCCIEIIRABBGJAAQDAKIAIIxiBhE
          IYwZDAGAGAQiBAFEEJwQyjCAAMBAgABGEZgoQCGQAEYhiBjCMYwoiIGACIgwCCBCQQAIR
          CCMEEYwAAACIYAQhAKAAEYQDAjAMYwIyDEQEAARhBEAchAQRBEECAQhAAAEMgQISCCAIY
          QgBBCAEIAQBiKMAAIgABiAIAAQQCCEIAAxhCBCIYAJxgCIAEoAkBAAIQQIgACMAIAiABl
          AMggIREIIEMQBEAiGUIwIhmAIAAAwDABCIAwwiBEAKIYBCAhGARQIBhCEGAQggAiEIRAA
          iCAECEAhgBiGMYQQxmKIEEAQkBCMIIQAiBCMCUIBhAAGQAAIhHCEYAYQEADKAAgQBDIgC
          IgBjBACEJAoBhCQAAQggAAEEBQISECEEMQgBABCMIQgSgMUEAYDBAAAEJgZABAICEAACA
          iKAAQACBEEGQIwgBkAAYAQgBCEAAJgABBKIZwIQACEAEQjAAgCIQQAAiCIMIIQjAhGEAQ
          hBBCEEMRBjAgGIBAISDGQEUQxBABCMIAIxgCAAIIwkBiEAAgYwBCQMQoBgBAAIIAICGEA
          CEIgjAACQIgJQDAMAMAxiAiAAQAYQgEEGEIQiAkIMAgwQBIMAEAxHBBAEQQZhgGICEoQj
          CBAUAQoAgCIGAQghBiCQZQQwhCIIEAyEBACAIQBDDCEEIYAiAACAYAIglCMCQgDjAjAAh
          AgQDUQEQIwiAiCYQwJBgEAGQIBEBgKAgwISCGEGEQCBBgCIZwYBBGEAAQUgABAAYAQACG
          AGARBmAjCAIQARAEEAEBBCBCAIIQpBCIAIEIggBDEEQgJRiEIAEAihBDGIAgISAAAIARC
          BAmKEIQIxlCAAIZCAABEUZAAhBAQEAYQkCACMIAoBCAIOAIRiABCIQQYEDIMEAJAhDACA
          IQAAiEEAAJAiAjAFARAQEEEIIABDEACEYAQgCKEIAYRDAACIRQhAiEMAQZChADAIQAIhA
          AICEgEjAhOQAQIQjAMCIwyBBHCMAQIgAAIGEIBEBCIMQgIRgGAAAIgCBDCEQgAwkEIEEY
          hDBkAEIQIQgAMEEYAiBjAAQgARCAMCIICCBGAIoQJgGKEAYIhBBCCAIAQSBEEEAQQhApE
          EIAAiEGAGE5AgAhEcIgISAOEAMQxDBDCYYAghBAIEEJQhAGAIJAYxBCYCEgQBBgCEAAZB
          gGIEQYwgAiAgoQZShEEEAIQgAhCEAQwBGAACAAAgBjEAAQYACCAAEIChAgEIAAQgFEEAE
          QRAAiIEIQohiEAGI4hCBgIQAQQgiEAAIISgBAEIAAiCBAIGMYghBECEBAJBDQEGIAAgBD
          GAQgAQhIEAAYCGBhCEYQJBhCMEIQgCBCGI4wAQDCIEIwRiEBAEYAAABIIAEARBAhAMQQQ
          gFAICkJhFCCGEAwIxhAICEABgBoEQAAIwEGcCAYggEDGQgRQAiCIAIIQCAjAQQQYBgGAI
          EARCBCQEoQQBAIECMhABAAAAIQAxhCMAMAhABgCIgQhAkEIAIJghAFAIRAghDSAEEBCEA
          BAQBAAwCMAAEoRECiAIQAAQpEEOQQgBBBAEwAAxDEEGEACDAiCEIBBiAAMIMIQAAAMEYA
          AgDGEOAICFBgGMBAgRFCEIAIwACiMIIQIgBEAAAABg"))

        expect(hllp.format).to eq(:normal)
        expect(hllp.p).to eq(11)
        expect(hllp.sp).to eq(16)
        expect(hllp.cardinality).to eq(3002)
      end
    end

    it 'unserializes a normal format instance with cardinality ~5759' do
      hllp = HyperLogLogPlus.unserialize(Base64.decode64("
        /////gsQANgKChEIQwYSCKMEQRBCADEIRwZCBGQEIhAkBjGAQQJEBKMEMhAkBjEIogAyBKI
        GQghDBjOEYQSAhCIEgIgGCAEEZgQSkEQIEZAEAhAEQwYxGKEIEICiBBQYRQghhEUCEqCFBi
        CMpQgxDGYIMIAhAiEEQggwnGACAhRBDiIUogowmEUEQRRjAjCNAgIhCMQMIChDCGCYAgQgi
        GEEIgiAAgEJQgAQgGMGMBBkAlGIxQYxiIIKEIihBCIFYQhRCCUGIo0CCDCMhARSCEMIQogj
        BACIQgoRDKIEQhBBBoKMIgZSiEACMwRmADMIQgYQiGIGQQxBCjIQggYBiGIMQIiiAkIIgwY
        yBScKQZRDABCMIgpAmMEEIYxECjGEJQwRAEIEEohCCBEMZQggBCEEQRBLBgAMIAhBmGICUY
        wiAhCUBAYQjMUEgQSFCCEMYQgRFGUGAYxDCkCMoQoRhEMGQISDCEEMRAYxjAIGMwxABEOkJ
        ARBAEMQYIyCDCCMYwoxBIMGcYgBADGEZwACkMMIUgQEBEENAgIykKMEIghkBDCAZgRhGCEG
        UQQjAjIIIQITjOQEEISBCiEEYQCCjMIIMhCjBCIEQghBBCEIM4xFAiEEIQZhDGQIQ4RhDEG
        IZAYRDAIEMYhDBECEowYwBIMEUgSiAkGEZgwhBEMEMgBlBhGIogAhBCUAUoyFCEKIQAARiI
        QGUQhiBhGQogQxGGEGUZBjBACMRgQxGIQQIJBQBhEQJARRBEICEAwiCDGUJARAhQEIEhgjA
        DGQIQJRjGEAMIxDBCGJBApBDAMEFBGDDCIMQgoSCGMGQYRDBjOIAwJSDKIEERSCACEEBAYQ
        jKAII5AlCCEIIwohiEIGMIwjEiMYQgghiCIMUowkBkCIYwZClCICIxhCAiGYAQYRhGEEYQx
        CCECMYgZBlGEIUQQjBCIIIgQTDMIOEQSEBBGUQwYBhMQGIhhEBkCIYwhDBCcEIQxhCCEAow
        YABCMEIZRCBiEIhgIhDEIUIYgjABIIQgIxEGQGUYDBBmGIhAIzBCIEMAhABhEEJgRBkEQGJ
        BDlBiAEwQoxiEQOEQgEDiGUYgZyDKIEIQ0BAAGUogIRBKMOFAiiBAEEJw5BiIMIQQRBDCEU
        QAIShGIGMZBhAjEQQgZCCKQCQZBiCjCQZghRDCMGQQhCBFIIgQQhlEQGIRBiFBMAIQJhCCM
        CIxRiAHIEQgYinEICMgDCDjIMIgIiECMMEqDJBiIgowYxCGACIIwjADEIQAYyGEAEYhQEBC
        EQggZwiCAKMIgiBiOYZwYShCEIIIwAChGMIwYgjEIGEYwpCBGIwwJilEMIUYTBCEEMQQ4hE
        CICIIwkCCEAQghBIIMAMBAkCICMogQhgEIGEYghBiGUJAQChGMEQIwmCDGYAgwjDGEKQY0j
        BjEIBgARkGEGQIggAjEIQwgQlMIEIZQhEiKMxAYzkGMGghSnACGFAwQxlEAIMgQgBiIcYwY
        hAGUIMgVCBjEQ4gQxiGEGQwhqBBOMoQRRjEEGIgSACDGEIQJihEQEMYSCBjIEYAIwBKYEIg
        xjBiCIggoBEEMEABRCBFGQIgRhkEEKEQyFCgEIQQJBCGIIEIxmAjGUggAihCMGkIhEBEEMY
        gZQGGMEAIhHAgQMQwRBBCEIAYkDCJGMQQIQCOUCIgxiCCEgAggQDGMAQogiBEIUJAhBAIIK
        AgykAkEEZAYwgQEEMpBlAiAMYgpRiCQEEIRCAnOIYwAiiEkEMJBFDkEQogQwjGgEIgwhCkG
        IQAoghIMCIYRjAkEUhQwxEGAKEAxECiGIRAQhCCQGEZiEEEMQZQQAmGEAAAAh"))

      expect(hllp.format).to eq(:normal)
      expect(hllp.p).to eq(11)
      expect(hllp.sp).to eq(16)
      expect(hllp.cardinality).to eq(5922)
    end
  end
end
