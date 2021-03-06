require 'spec_helper'
require 'base64'
require 'hyperll'
require 'json'

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

    describe 'serialization' do
      it 'serializes a sparse format to a string' do
        # TODO: We can't yet construct a HyperLogLogPlus from scratch, so we
        # deserialize a HyperLogLogPlus from stream-lib, then serialize it
        # back and make sure it matches.

        # h = Java::com::clearspring::analytics::stream::cardinality::HyperLogLogPlus.new(4, 10)
        # h.offer(1)
        # h.offer(2)
        # h.getBytes()
        serialized = [-1, -1, -1, -2, 4, 10, 1, 2, -46, 5, -64, 4].pack("C*")

        hllp = HyperLogLogPlus.unserialize(serialized)
        expect(hllp.serialize).to eq(serialized)
      end

      it 'serializes a normal format to a string' do
        # TODO: We can't yet construct a HyperLogLogPlus from scratch, so we
        # deserialize a HyperLogLogPlus from stream-lib, then serialize it
        # back and make sure it matches.

        # h = Java::com::clearspring::analytics::stream::cardinality::HyperLogLogPlus.new(4)
        # h.offer(1)
        # h.offer(2)
        # h.getBytes()
        serialized = [-1, -1, -1, -2, 4, 0, 0, 12, 2, 0, 0, 0, 0, 48, 0, 0, 0, 0, 0, 0].pack("C*")

        hllp = HyperLogLogPlus.unserialize(serialized)
        expect(hllp.serialize).to eq(serialized)
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

      it 'converts from sparse to normal' do
        hllp = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 10, 1, 3, -46, 5, 50, -114, 4].pack("C*"))

        expect(hllp.format).to eq(:sparse)
        expect(hllp.cardinality).to eq(3)

        hllp.convert_to_normal
        expect(hllp.format).to eq(:normal)
        expect(hllp.cardinality).to eq(3)
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

      it 'unserializes a sparse format instance from a string' do
        # hllp = Java::com::clearspring::analytics::stream::cardinality::HyperLogLogPlus.new(4, 10)
        # hllp.offer(1)
        # hllp.offer(2)
        # h.getBytes()
        serialized = [-1, -1, -1, -2, 4, 10, 1, 2, -46, 5, -64, 4].pack("C*")
        hllp = HyperLogLogPlus.unserialize(serialized)

        expect(hllp.format).to eq(:sparse)
        expect(hllp.p).to eq(4)
        expect(hllp.sp).to eq(10)
        expect(hllp.cardinality).to eq(2)
      end
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

    it 'unserializes a sparse format instance with cardinality 2' do
      hllp = HyperLogLogPlus.unserialize(Base64.decode64("/////gsQAQLC3gKCxQM="))

      expect(hllp.format).to eq(:sparse)
      expect(hllp.p).to eq(11)
      expect(hllp.sp).to eq(16)
      expect(hllp.cardinality).to eq(2)
    end

    it 'unserializes a sparse format instance with cardinality 4' do
      hllp = HyperLogLogPlus.unserialize(Base64.decode64("/////gsQAQSglAPiIdbJAfga"))

      expect(hllp.format).to eq(:sparse)
      expect(hllp.p).to eq(11)
      expect(hllp.sp).to eq(16)
      expect(hllp.cardinality).to eq(4)
    end
  end

  describe 'merging' do
    context 'of different sizes' do
      it 'raises an error' do
        hllp = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 11, 25, 1, 0].pack("C*")) # 11, 25
        hllp2 = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 12, 24, 1, 0].pack("C*")) # 12, 24

        expect {
          hllp.merge(hllp2)
        }.to raise_error(ArgumentError)
      end
    end

    context 'sparse with sparse' do
      it 'merges and keeps the cardinality exact' do
        hllp = HyperLogLogPlus.unserialize(Base64.decode64("/////gsQAQLC3gKCxQM="))
        hllp2 = HyperLogLogPlus.unserialize(Base64.decode64("/////gsQAQSglAPiIdbJAfga"))

        hllp.merge(hllp2)
        expect(hllp.cardinality).to eq(6)
      end

      it 'merges and keeps the cardinality exact, handling elements that are common to both sets' do
        # Serialization after offering [12, 13, 22, 34, 38, 40, 41, 46, 49]
        hllp = HyperLogLogPlus.unserialize(Base64.decode64("/////gsQAQnMYsoMtgak9AGMiwK8VbKiAYmU0wPVwK38Dw=="))

        # Serialization after offering [2, 6, 19, 29, 41, 48]
        hllp2 = HyperLogLogPlus.unserialize(Base64.decode64("/////gsQAQbwdJz0Afq4AbSZAqxX4i4="))

        expect(hllp.cardinality).to eq(9)
        expect(hllp2.cardinality).to eq(6)

        # The set intersection of hllp and hllp2 has one element, 41, so after
        # merging the cardinality should be 14.
        hllp.merge(hllp2)
        expect(hllp.cardinality).to eq(14)
      end

      it 'merges and keeps the cardinality exact' do
        hllp = HyperLogLogPlus.unserialize(Base64.decode64("/////gsQAQOwX+yBA7TzAw=="))
        hllp2 = HyperLogLogPlus.unserialize(Base64.decode64("/////gsQAQ7SKbociFqGigLUL9oagCWmC+IdlBqkE8g7jFiCnwE="))

        hllp.merge(hllp2)
        expect(hllp.cardinality).to eq(17)
      end

      it 'merges with another instance with some of the same elements' do
        hllp = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 11, 16, 1, 3, -116, -23, 2, -90, 25, -66, -121, 2].pack("C*"))
        hllp2 = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 11, 16, 1, 3, -116, -23, 2, -90, 25, -6, -96, 4].pack("C*"))

        expect(hllp.cardinality).to eq(3)
        expect(hllp2.cardinality).to eq(3)

        hllp.merge(hllp2)
        expect(hllp.cardinality).to eq(4)
      end
    end

    context 'normal with normal' do
      it 'merges, though the cardinality may not come out exactly' do
        hllp = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 0, 0, 12, 2, 0, 0, 0, 0, 48, 0, 5, 0, 0, 0, 0].pack("C*"))
        hllp2 = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 0, 0, 12, 0, 0, 0, 32, 4, 0, 0, 0, 0, 0, 4, 0].pack("C*"))

        expect(hllp.cardinality).to eq(3)
        expect(hllp2.cardinality).to eq(3)

        hllp.merge(hllp2)
        expect(hllp.cardinality).to eq(8) # 3 + 3 = 8; that's how it goes with hll
      end
    end

    context 'sparse with normal' do
      it 'merges, converting the sparse to a normal' do
        hllp = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 10, 1, 3, -46, 5, 50, -114, 4].pack("C*"))
        hllp2 = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 0, 0, 12, 0, 0, 0, 32, 4, 0, 0, 0, 0, 0, 4, 0].pack("C*"))

        expect(hllp.format).to eq(:sparse)
        expect(hllp.cardinality).to eq(3)
        expect(hllp2.format).to eq(:normal)
        expect(hllp2.cardinality).to eq(3)

        hllp.merge(hllp2)
        expect(hllp.format).to eq(:normal)
        expect(hllp.cardinality).to eq(8) # 3 + 3 = 8; that's how it goes with hll
      end
    end

    context 'normal with sparse' do
      it 'merges, though the cardinality may not come out exactly' do
        hllp = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 0, 0, 12, 0, 0, 0, 32, 4, 0, 0, 0, 0, 0, 4, 0].pack("C*"))
        hllp2 = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 10, 1, 3, -46, 5, 50, -114, 4].pack("C*"))

        expect(hllp.format).to eq(:normal)
        expect(hllp.cardinality).to eq(3)
        expect(hllp2.format).to eq(:sparse)
        expect(hllp2.cardinality).to eq(3)

        hllp.merge(hllp2)
        expect(hllp.format).to eq(:normal)
        expect(hllp.cardinality).to eq(8) # 3 + 3 = 8; that's how it goes with hll
      end
    end

    context 'merging multiple at a time' do
      it 'merges' do
        hllp = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 10, 1, 1, -110, 10].pack("C*"))
        hllp2 = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 10, 1, 1, -46, 5].pack("C*"))
        hllp3 = HyperLogLogPlus.unserialize([-1, -1, -1, -2, 4, 10, 1, 1, -124, 6].pack("C*"))

        hllp.merge(hllp2, hllp3)
        expect(hllp.format).to eq(:sparse)
        expect(hllp.cardinality).to eq(3) # 1 + 1 + 1 = 3
      end
    end
  end
end
